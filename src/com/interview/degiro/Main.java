package com.interview.degiro;
import java.util.Scanner;

public class Main {
    public static int [][] raceTrack;
    public static int [][] startPoint;
    public static int [][] endPoint;
    public static int [][] obstaclesStartPoint;
    public static int [][] obstaclesEndPoint;
    public static int obX1;
    public static int obX2;
    public static int obY1;
    public static int obY2;
    public static int countHops = 0;


    public static void main(String[] args) {

        Scanner scan = new Scanner(System.in);
        int testCase = Integer.parseInt(scan.nextLine());
        int row = 0;
        int col = 0;

        for(int i=0; i < testCase; i++){
            String [] dimension = scan.nextLine().split(" ");
            row = Integer.parseInt(dimension[0]);
            col = Integer.parseInt(dimension[1]);
            raceTrack = new int [row][col];

            String []  grid = scan.nextLine().split(" ");
            int x1 = Integer.parseInt(grid[0]);
            int y1 = Integer.parseInt(grid[1]);
            int x2 = Integer.parseInt(grid[2]);
            int y2 = Integer.parseInt(grid[3]);
            startPoint = new int [x1][y1];
            endPoint = new int [x2][y2];

            int obstacles = Integer.parseInt(scan.nextLine());
            for (int j = 0; j < obstacles; j++) {
                String []  obstaclesGrid = scan.nextLine().split(" ");
                obX1 = Integer.parseInt(obstaclesGrid[0]);
                obY1 = Integer.parseInt(obstaclesGrid[1]);
                obX2 = Integer.parseInt(obstaclesGrid[2]);
                obY2 = Integer.parseInt(obstaclesGrid[3]);
                obstaclesStartPoint= new int [obX1][obY1];
                obstaclesEndPoint= new int [obX2][obY2];
            }
            solve(row,col,raceTrack);
            if(countHops>0){
                System.out.printf("Optimal solution takes %d hops.",countHops);
                System.out.println();
                countHops = 0;
            }else{
                System.out.println("No solution.");
            }

        }
    }


    static void solve( int row, int col, int[][] raceTrack){
        if(outOfTrack(row,col)){
            return;
        }

        for ( int hopperX = 0 ; hopperX < raceTrack.length; hopperX++ ){
            for (int hopperY = 0; hopperY < raceTrack[hopperX].length ; hopperY++) {
                if((hopperX == obX1 && hopperY == obY1) || (hopperX == obX2 && hopperY == obY2)){
                    continue;
                } else {
                    countHops++;
                }

            }
        }
    }

    private  static boolean outOfTrack(int row, int col){
        if(row < 1 || row > raceTrack[0].length || row > 30){
            return true;
        }
        if(col < 1 || col >raceTrack[1].length || col> 30 ){
            return true;
        }
        return false;
    }



   /*
    2 test case

    5 5  race track
    4 0 4 4 start and end point
    1        obstacles
    1 4 2 3  coordinate of obstacles

    3 3      second test race track
    0 0 2 2
    2        obstacles
    1 1 0 2
    0 2 1 1
*/

   /*
Optimal solution takes 7 hops.
No solution.


    */
}
