using System;
using System.Collections;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using jabber.client;
using jabber.protocol.client;

namespace winButtonsCommon
{
    public class JabberWrapper
    {
        
        private JabberClient client;

        public JabberWrapper(string username, string password, string server)
        {
            this.client = new JabberClient();
            this.client.User = username;
            this.client.Password = password;
            
            //perhaps needed ?
            //this.client.NetworkHost = "talk.l.google.com";

            //a few settings not gonng work with SSL for some reason 
            this.client.SSL = false;

            this.client.OnError += new bedrock.ExceptionHandler(this.Error);
            this.client.OnAuthenticate += new bedrock.ObjectHandler(this.Authenticate);

            this.client.OnMessage += new jabber.client.MessageHandler(this.MessageRead);
            this.client.OnReadText += new bedrock.TextHandler(this.TextRead);
            this.client.OnWriteText += new bedrock.TextHandler(this.TextSend);
        }

        public void Connect() {
            this.client.Connect();
        }

        public void Close() {
            this.client.Close();
        }

        public void Message(string target, string msg) {
            this.client.Message(target, msg);
        }

        private void Error(object sender, Exception ex)
        {
            Logger.Info("OnError :" + ex.Message);
        }

        private void TextSend(object sender, string msg)
        {
            if (msg == " ") {
                return;  // ignore keep-alive spaces
            }
            Logger.Info("SEND: " + msg);
        }

        private void TextRead(object sender, string msg)
        {
            if (msg == " ") {
                return;  // ignore keep-alive spaces
            }
            Logger.Info("RECV: " + msg);
        }

        private void MessageRead(object sender, Message msg) {
            this.OnMessageEvent(msg.Body);
        }

        private void Authenticate(object sender) {
            Logger.Info("OnAuthenticate");
            OnAuthenticateEvent();
        }


        public delegate void AuthenticateEventHandler();
        private AuthenticateEventHandler OnAuthenticateEvent;

        public event AuthenticateEventHandler OnAuthenticate
        {
            add
            {
                OnAuthenticateEvent = (AuthenticateEventHandler)System.Delegate.Combine(OnAuthenticateEvent, value);
            }
            remove
            {
                OnAuthenticateEvent = (AuthenticateEventHandler)System.Delegate.Remove(OnAuthenticateEvent, value);
            }
        }

        public delegate void MessageEventHandler(string msg);

        private MessageEventHandler OnMessageEvent;

        public event MessageEventHandler OnMessage
        {
            add
            {
                OnMessageEvent = (MessageEventHandler)System.Delegate.Combine(OnMessageEvent, value);
            }
            remove
            {
                OnMessageEvent = (MessageEventHandler)System.Delegate.Remove(OnMessageEvent, value);
            }
        }
    }
}
