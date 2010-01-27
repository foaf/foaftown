using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace winButtonsCommon
{
    public partial class Logger
    {
        private const string PATH = "C:/Program Files/WinButtons/winButtons/log.txt";
        public static void Info(String obj)
        {
            string log = DateTime.Now.ToString() + " - " + obj + Environment.NewLine;
            //PATH, log
            if (!File.Exists(PATH)) {
                FileStream fs = File.Create(PATH);
                fs.Close();
            }

            try {
              StreamWriter sw = File.AppendText(PATH);
              sw.WriteLine(log);
              sw.Flush();
              sw.Close();
            } finally {}
        }
    }
}