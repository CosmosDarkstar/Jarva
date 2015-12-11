package skewll.ch10.challenge;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.SwingUtilities;
import javax.swing.Timer;

public class Car extends JComponent {

	private static final long serialVersionUID = 1L;
	private final int windowHeight = 700;
	private final int windowWidth = 900;
	private int width = 100;
	private int height = 50;
	private final int timerDelay1 = 30;
	private int x1 = 10;
	private int y1 = 10;
	private int x2 = 890;
	private int y2 = 590;

	public Car() {
		new Timer(timerDelay1, new ActionListener() {
			public void actionPerformed(ActionEvent actEvt) {
				if (x1 < windowWidth && y1 < windowHeight) {
					x1 = x1 + 2;
					x2 = x2 - 2;
					repaint();
				} else if (x1 >= windowWidth) {
					x1 = 0;
					x2 = 990;
				} else {
					((Timer) actEvt.getSource()).stop();
				}
			}
		}).start();

	}

	public Dimension getPreferredSize() {
		return new Dimension(windowWidth, windowHeight);

	}

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		g.setColor(Color.red);
		g.drawRect(x1, y1, width, height);
		g.fillRect(x1, y1, width, height);
		g.setColor(Color.blue);
		g.drawRect(x2, y2, width, height);
		g.fillRect(x2, y2, width, height);
	}

	public static void guiMake() {
		Car boop = new Car();
		JFrame fram = new JFrame("Car");
		fram.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		fram.getContentPane().add(boop);
		fram.pack();
		fram.setLocationByPlatform(true);
		fram.setVisible(true);
	}

	public static void main(String[] args) {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				guiMake();
			}
		});
	}

}
