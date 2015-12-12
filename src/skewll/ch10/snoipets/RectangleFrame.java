package skewll.ch10.snoipets;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JFrame;
import javax.swing.Timer;

/**
 * This frame contains a moving rectangle.
 */
public class RectangleFrame extends JFrame {
	private static final int FRAME_WIDTH = 300;
	private static final int FRAME_HEIGHT = 400;
	private int moveX = 1;
	private int moveY = (int) Math.random();

	private RectangleComponent scene;

	class TimerListener implements ActionListener {
		public void actionPerformed(ActionEvent event) {
			if (RectangleComponent.BOX_X < 0 || (RectangleComponent.BOX_X + RectangleComponent.BOX_WIDTH) > FRAME_WIDTH) {
				moveX = -moveX;

			}

			if (RectangleComponent.BOX_X < 0) {
				moveX = 0;
			} else if (RectangleComponent.BOX_X > FRAME_WIDTH) {
				moveX = FRAME_WIDTH;
			} else {
				moveX = RectangleComponent.BOX_X + moveX;
			}
			scene.moveRectangleBy(moveX, moveY);
		}
	}

	public RectangleFrame() {
		scene = new RectangleComponent();
		add(scene);

		setSize(FRAME_WIDTH, FRAME_HEIGHT);

		ActionListener listener = new TimerListener();

		final int DELAY = 100; // Milliseconds between timer ticks
		Timer t = new Timer(DELAY, listener);
		t.start();
	}
}
