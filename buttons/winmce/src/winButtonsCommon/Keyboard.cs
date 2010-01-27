using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace winButtonsCommon
{
    public static class Keyboard
    {
        public const int LEFT = 37;
        public const int RIGHT = 39;
        public const int UP = 38;
        public const int DOWN = 40;
        public const int ESCAPE = 27;
        public const int BACK = 8;
        public const int MEDIA_NEXT_TRACK = 176;
        public const int MEDIA_PREV_TRACK = 177;
        public const int MEDIA_STOP = 178;
        public const int MEDIA_PLAY_PAUSE = 179;
        public const int RETURN = 13;


        private const uint INPUT_KEYBOARD = 1;
        private const int KEY_EXTENDED = 0x0001;
        private const uint KEY_UP = 0x0002;
        //  private const uint KEY_SCANCODE = 0x0004;  //unicode 0x0008 Key_
        private const uint KEYEVENTF_UNICODE = 0x0004; //THIS WORKS AS DEFAULT FLAG
        private const uint KEYEVENTF_SCANCODE = 0x0008;   //IF I USE THIS I THE FLAGS STRANGE RESULTS

        [StructLayout(LayoutKind.Sequential)]
        private struct KEYBOARD_INPUT
        {
            public uint type;
            public ushort vk;
            public ushort scanCode;
            public uint flags;
            public uint time;
            public uint extrainfo;
            public uint padding1;
            public uint padding2;
        }

        [DllImport("User32.dll")]
        private static extern uint SendInput(uint numberOfInputs,
        [MarshalAs(UnmanagedType.LPArray, SizeConst = 1)] KEYBOARD_INPUT[] input,
        int structSize);


        public static void Send(int scanCode)
        {
            SendKey(scanCode, true);
            SendKey(scanCode, false);
        }
        
        private static void SendKey(int scanCode, bool press)
        {
            KEYBOARD_INPUT[] input = new KEYBOARD_INPUT[1];
            input[0] = new KEYBOARD_INPUT();
            input[0].type = INPUT_KEYBOARD;
            input[0].flags = KEYEVENTF_UNICODE;

            if ((scanCode & 0xFF00) == 0xE000)
            { // extended key?
                input[0].flags |= KEY_EXTENDED;
            }

            if (press)
            { // press?
                input[0].scanCode = (ushort)(scanCode & 0xFF);
            }
            else
            { // release?
                input[0].scanCode = (ushort)scanCode;
                input[0].flags |= KEY_UP;
            }

            uint result = SendInput(1, input, Marshal.SizeOf(input[0]));

            if (result != 1)
            {
                Logger.Info("Could not send key" + result);
            }
        }
    }
}
