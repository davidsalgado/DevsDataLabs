using System;
using System.Threading;

using Microsoft.Rest.Azure.Authentication;
using Microsoft.Azure.Management.DataLake.Store;
using Microsoft.Azure.Management.DataLake.StoreUploader;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Azure.Management.DataLake.Store.Models;
using System.IO;
using System.Text;

namespace HelloDataLake
{
    class Program
    {
        private static DataLakeStoreFileSystemManagementClient _adlsFileSystemClient;

        private static string _adlsAccountName;
        private static string _subId;

        private static void Main(string[] args)
        {
            // TODO: 1. Provide the name of your existing Data Lake Store account.
            _adlsAccountName = "hello";

            // TODO: 1. Replace with the subscription ID of the Azure Subscription containing your Data Lake Store account.
            _subId = "e223f1b3-d19b-4cfa-98e9-bc9be62717bc";

            string fileName = "MSFT-history.csv";
            string localFolderPath = AppDomain.CurrentDomain.BaseDirectory; 
            string localFilePath = localFolderPath + fileName;
            string remoteFolderPath = "/stock_prices/";
            string remoteFilePath = remoteFolderPath + fileName;

            var creds = InteractiveLogin();

            // TODO: 3. Create file system client object 
            _adlsFileSystemClient = //...

            UploadFile(localFilePath, remoteFilePath);
            Console.WriteLine("File uploaded");

            var files = ListItems(remoteFolderPath);
            Console.WriteLine("Folder contents:");
            foreach (var file in files)
            {
                Console.WriteLine(file.PathSuffix);
            }

            DownloadFile(remoteFilePath, localFilePath);
            Console.WriteLine("File downloaded");
        }

        // Login with a dialog user interface
        public static Microsoft.Rest.ServiceClientCredentials InteractiveLogin()
        {
            // Uses the client ID of an existing AAD "Native Client" application that is present by default in all AAD accounts.
            SynchronizationContext.SetSynchronizationContext(new SynchronizationContext());
            var domain = "common";  
            var nativeClientApp_clientId = "1950a258-227b-4e31-a9cf-717495945fc2";
            var activeDirectoryClientSettings = ActiveDirectoryClientSettings.UsePromptOnly(nativeClientApp_clientId, new Uri("urn:ietf:wg:oauth:2.0:oob"));

            //TODO: 4. Display the dialog to prompt user login
            var creds = UserTokenProvider.//...;

            return creds;
        }

        // Upload the file
        public static void UploadFile(string srcFilePath, string destFilePath, bool force = true)
        {
            //TODO: 5. Configure the file upload
            var parameters = new UploadParameters(/*...*/);
            var frontend = new DataLakeStoreFrontEndAdapter(/*...*/);
            var uploader = new DataLakeStoreUploader(/*...*/);

            //TODO: 6. Upload the file
            uploader.//...
        }

        // List files and directories under the provided path
        public static List<FileStatusProperties> ListItems(string directoryPath)
        {
            //TODO: 7. Retrieve the list of files under the provided folder.
            return _adlsFileSystemClient.//...
        }

        // Download file
        public static void DownloadFile(string srcPath, string destPath)
        {
            //TODO: 8. Open a stream to the file in Azure Data Lake Store
            var stream = //...

            //TODO: 9. Copy the stream to a local file
            var fileStream = //...
            stream.CopyTo(/*...*/);

            fileStream.Close();
            stream.Close();
        }
    }
}