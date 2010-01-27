using System.Collections.Generic;
using Microsoft.MediaCenter.Hosting;

namespace winButtons
{
    public class MyAddIn : IAddInModule, IAddInEntryPoint
    {

        public void Initialize(Dictionary<string, object> appInfo, Dictionary<string, object> entryPointInfo)
        {
        }

        public void Uninitialize()
        {
        }

        public void Launch(AddInHost host)
        {
            Application app = new Application(host);
            app.Start();
        }
    }
}