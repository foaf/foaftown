package tv.foaf.chirp;

import org.jfugue.*;
import org.jfugue.extras.*;

// started with http://www.jfugue.org/examples.html

class Chirp {

public static void main(String a[]) {

  Rhythm rhythm = new Rhythm();
 
  //  Bang out your drum beat	
  rhythm.setLayer(1, "O..oO...O..oOO..");
  rhythm.setLayer(2, "..*...*...*...*.");
  rhythm.setLayer(3, "^^^^^^^^^^^^^^^^");
  rhythm.setLayer(4, "...............!");
  //  Associate percussion notes with your beat	
  rhythm.addSubstitution('O', "[BASS_DRUM]i");
  rhythm.addSubstitution('o', "Rs [BASS_DRUM]s");
  rhythm.addSubstitution('*', "[ACOUSTIC_SNARE]i");
  rhythm.addSubstitution('^', "[PEDAL_HI_HAT]s Rs");
  rhythm.addSubstitution('!', "[CRASH_CYMBAL_1]s Rs");
  rhythm.addSubstitution('.', "Ri");

  //  Play the rhythm!	
  Pattern pattern = rhythm.getPattern();
  pattern.repeat(4);
  Player player = new Player();
  player.play(pattern);

}

} // end class
