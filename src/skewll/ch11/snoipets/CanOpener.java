package skewll.ch11.snoipets;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.Scanner;

public class CanOpener {

	public static void main(String[] args) throws FileNotFoundException {

		File pie = new File("hello.txt");
		Scanner eat = new Scanner(pie);
		PrintWriter servingSpoon = new PrintWriter("hello.txt");
		servingSpoon.print("Hello world");

		String pizza = eat.nextLine();

		System.out.println(pizza);

		eat.close();
		servingSpoon.close();

	}

}
