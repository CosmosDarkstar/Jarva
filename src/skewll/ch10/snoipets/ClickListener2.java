package skewll.ch10.snoipets;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 * An action listener that prints a message.
 */
public class ClickListener2 implements ActionListener {
	private static int i = 0;
	private static int count = 0;

	public void actionPerformed(ActionEvent event) {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
		System.out.println(sdf.format(cal.getTime()));
		i++;
		System.out.println("Button B was clicked " + i + " times. ");

	}

}
