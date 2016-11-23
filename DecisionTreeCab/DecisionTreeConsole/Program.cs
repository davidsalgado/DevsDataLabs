using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DecisionTreeConsole
{
    class Program
    {
        static string _connectionString;

        static void Main(string[] args)
        {
            _connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["SqlConnection"].ConnectionString;

            Console.WriteLine("How long will the tax ride be (in miles)?");
            var input = Console.ReadLine();
            double distance = 0;

            if (double.TryParse(input, out distance))
            {
                Console.WriteLine("Predicting Tip for Taxi Rides...");
                Console.WriteLine();
                PredictTipUsingDecisionTree(distance);
            }
            else
            {
                Console.WriteLine("Unable to parse your entry. Please enter only a double value like 12.5");
            }

            Console.ReadLine();
        }

        private static void PredictTipUsingDecisionTree(double distance)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(_connectionString))
                {
                    conn.Open();

                    // Execute the stored procedure
                    using (SqlCommand cmd = new SqlCommand("PredictTipUsingDecisionTree", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("trip_distance", distance));
                        var result = cmd.ExecuteScalar();

                        Console.ForegroundColor = ConsoleColor.Cyan;
                        Console.WriteLine("Distance: {0} miles", distance);
                        Console.WriteLine("Prediction: {0}",(double) result > 0.5 ? "TIP" : "NO TIP");
                        Console.ResetColor();
                    }

                    conn.Close();
                }
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(ex.Message);
                Console.ResetColor();
            }
        }

    }
}
