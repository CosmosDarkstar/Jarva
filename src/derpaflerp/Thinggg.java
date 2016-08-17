package derpaflerp;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.swing.AbstractAction;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JTextField;

public class Thinggg implements MouseListener {
	private static JFrame frame = new JFrame("dorp");
	private static BorderLayout lay = new BorderLayout();
	protected static JTextField vop = new JTextField();
	protected static JButton der = new JButton();
	protected static JButton de = new JButton();
	private static JLabel as;
	private static MouseListener boop = new Thinggg();
	private static MouseListener bop = new Thinggg();

	public static void main(String[] args) {
		Menu();
	}

	private static void Menu() {
		frame.setSize(400, 400);
		lay.setHgap(10);
		lay.setVgap(5);
		frame.setLayout(lay);

		der.setText("START");
		de.setText("EXIT");
		de.addMouseListener(boop);
		der.addMouseListener(bop);

		vop.setText("Click start to begin quest or quit to exit program.");

		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		frame.add(vop, BorderLayout.NORTH);
		frame.add(der, BorderLayout.WEST);
		frame.add(de, BorderLayout.EAST);

		frame.pack();
		frame.setLocationRelativeTo(null);
		frame.setVisible(true);
	}

	private static void QuestBegin() {

	}

	@Override
	public void mouseClicked(MouseEvent arg0) {
		// TODO Auto-generated method stub

	}

	@Override
	public void mouseEntered(MouseEvent arg0) {
		// TODO Auto-generated method stub

	}

	@Override
	public void mouseExited(MouseEvent arg0) {
		// TODO Auto-generated method stub

	}

	@Override
	public void mousePressed(MouseEvent arg0) {
		// TODO Auto-generated method stub

	}

	@Override
	public void mouseReleased(MouseEvent arg0) {
		// TODO Auto-generated method stub

	}

	public class Click extends AbstractAction {
		public Click() {

		}

		@Override
		public void actionPerformed(ActionEvent arg0) {
			// TODO Auto-generated method stub

		}
	}

}
