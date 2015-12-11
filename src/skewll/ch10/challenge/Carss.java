package skewll.ch10.challenge;

/* being used to base off of. not for actual */

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.SwingUtilities;
import javax.swing.Timer;

public class Carss extends JComponent {

	private static final long serialVersionUID = 1L;
	private static final int windowWidth = 900;
	private static final int windowHeight = 700;
	private static final int TIMER_DELAY = 30;
	public int rectX = 10;
	public int rectY = 10;
	public int width = 100;
	public int height = 50;

	public Carss() {
		new Timer(TIMER_DELAY, new ActionListener() {

			//	@Override
			public void actionPerformed(ActionEvent actEvt) {
				if (rectX < windowWidth && rectY < windowHeight) {
					rectX = rectX + 2;
					repaint();
				} else {
					((Timer) actEvt.getSource()).stop();
				}
			}
		}).start();
	}

	//@Override
	public Dimension getPreferredSize() {
		return new Dimension(windowWidth, windowHeight);
	}

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		g.setColor(Color.red);
		g.drawRect(rectX, rectY, width, height);
		g.fillRect(rectX, rectY, width, height);
	}

	public int getRectX() {
		return rectX;
	}

	public void setRectX(int rectX) {
		this.rectX = rectX;
	}

	public int getRectY() {
		return rectY;
	}

	public void setRectY(int rectY) {
		this.rectY = rectY;
	}

	private static void createAndShowGui() {
		Carss mainPanel = new Carss();

		JFrame frame = new JFrame("Carss");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.getContentPane().add(mainPanel);
		frame.pack();
		frame.setLocationByPlatform(true);
		frame.setVisible(true);
	}

	public static void main(String[] args) {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				createAndShowGui();
			}
		});
	}

}
