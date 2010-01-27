using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.MediaCenter;
using Microsoft.MediaCenter.Hosting;
using Microsoft.MediaCenter.UI;
using winButtonsCommon;


namespace winButtons
{
    public class Application : ModelItem
    {
        private static Application singleApplicationInstance;
        private AddInHost host;
        private JabberWrapper xmpp;
        private string xmppTarget;
        private System.Threading.ManualResetEvent _waitForExit;

        public Application(AddInHost host)
        {
            this.host = host;
            singleApplicationInstance = this;
        }

        public MediaCenterEnvironment MediaCenterEnvironment
        {
            get
            {
                if (host == null)
                {
                    return null;
                }
                return host.MediaCenterEnvironment;
            }
        }
        private System.Int32 iHandle;
    
        public void Start()
        {

            // get Window handle
            iHandle = Win32.FindWindow(null, "Windows Media Center");
            Win32.SendMessage(iHandle, Win32.WM_COMMAND, 0x00004978, 0x00000000);

            //Keyboard.Send(Keyboard.UP);
            //Keyboard.Send(Keyboard.UP);

            //Keyboard.Send(Keyboard.RETURN);
     

            Dialog("WinButtons is running");

            //Keyboard.Send(Keyboard.UP);
            //Keyboard.Send(Keyboard.UP);

            //Keyboard.Send(Keyboard.RETURN);

            this.xmpp = new JabberWrapper("bob.notube", "gargonza", "gmail.com");
            
            //this.xmpp.Connect();
            this.xmpp.OnAuthenticate +=new JabberWrapper.AuthenticateEventHandler(onAuthenticate);
            this.xmpp.OnMessage += new JabberWrapper.MessageEventHandler(onMessage);
            
            this.xmppTarget = "alice.notube@gmail.com";

            // With the server up and running on a background thread, suspended this thread until the add-in closes.
            // Lower the priority of this thread so it receives as little CPU time as possible
            System.Threading.Thread.CurrentThread.Priority = System.Threading.ThreadPriority.Lowest;
            _waitForExit = new System.Threading.ManualResetEvent(false);
            _waitForExit.WaitOne();
        }

        private void onAuthenticate(){
            this.xmpp.Message(this.xmppTarget, "Hello from winButtons");
        }

        private void onMessage(string message)
        {
            Logger.Info("onMessage" + message);
            switch (message)
            {
                case "PLPZ event.":
                    break;
                case "LEFT event.":
                    //this.key.Send(VKey.LEFT);
                    break;
                case "RIGH event.":
                    //this.key.Send(VKey.RIGHT);
                    break;
                case "PLUS event.":
                    //this.key.Send(VKey.UP);
                    break;
                case "MINU event.":
                    //this.key.Send(VKey.UP);
                    break;
                case "LIKE event.":
                    break;
                case "MENU event.":
                    break;
            }
        }

        public void Dialog(string strClickedText)
        {
            int timeout = 5;
            bool modal = true;
            string caption = Resources.DialogCaption;

            if (host != null)
            {
                MediaCenterEnvironment.Dialog(strClickedText,
                                              caption,
                                              new object[] { DialogButtons.Ok },
                                              timeout,
                                              modal,
                                              null,
                                              delegate(DialogResult dialogResult) { });
            }
            else
            {
                Debug.WriteLine("DialogTest");
            }
        }
    }
}