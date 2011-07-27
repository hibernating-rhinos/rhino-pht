namespace Rhino.PersistentHashTable.Tests
{
	using System.IO;

	public class PersistentTestBase
	{
		protected const string testDatabase = "test.esent";

		public PersistentTestBase()
		{
            if (Directory.Exists(testDatabase))
                DeleteDirectory(testDatabase);
		}


        private static void DeleteDirectory(string rootDir)
        {
            var files = Directory.GetFiles(rootDir);
            var subDirectories = Directory.GetDirectories(rootDir);

            foreach (string file in files)
            {
                File.SetAttributes(file, FileAttributes.Normal);
                File.Delete(file);
            }

            foreach (string dir in subDirectories)
            {
                DeleteDirectory(dir);
            }

            Directory.Delete(rootDir, false);
        }
	}
}