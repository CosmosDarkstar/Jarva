package skewll.ch13.starter;

import java.util.ArrayList;

/**
   Attempts to find a path through a maze.
*/
public class Maze{
	private char[][] maze;
   private int width;
   private int height;
   private ArrayList<Coordinate> path;
   private boolean exit;

   /**
      Create a maze searcher.
      @param aMaze character array representation of maze
   */
   public Maze(char[][] aMaze){
      maze = aMaze;
      width = maze[0].length;
      height = maze.length;
      path = new ArrayList<Coordinate>();
   }

   /**
      Find an escape path.
      @param i row position
      @param j column position
      @return if escape is possible
   */
   public boolean escape(int i, int j){
     if(exit)
    	 return true;
     else
    	 return false;
   }

   /**
      Get the path through the maze.
      @return list of coordinates along path
   */
   public ArrayList<Coordinate> getPath(){
      return path;
   }

   /**
      Determine if the row, column location is an exit.
      @return if location is an exit
   */
   private boolean isExit(int i, int j){
	   exit=maze[i][j] == ' '
	            && (i == 0 || j == 0 || i == height - 1 || j == width - 1);
      return exit;
   }
}
