package skewll.ch13.starter;

import java.util.Scanner;

public class Numburzzzzzzzzzzzz {
	
	private static int grog;
	private int hat;
	
	public static int Factorial(int floobishipe){
		
		if(floobishipe==1)
			return 1;
		else{
			for(int i=1;i<=floobishipe;i++){
				grog=floobishipe*i;
			}
		}
		
		return grog;
	}
	
	public static int Fibonacci(int rage){
		
		if(rage<=1)return rage;
		else return Fibonacci(rage-1)+Fibonacci(rage-2);
	}

	public static void main(String[] args) {
		Scanner nom = new Scanner(System.in);
		System.out.println("put in int for factorial");
		int bloop = Factorial(nom.nextInt());
		System.out.println("factorial is "+bloop);
		System.out.println("put in int for fibonacci");
		int bum=Fibonacci(nom.nextInt());
		System.out.println("fibonacci is "+bum);
		nom.close();
		
	}

}
