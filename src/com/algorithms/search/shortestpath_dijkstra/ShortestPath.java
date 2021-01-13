package com.algorithms.search.shortestpath_dijkstra;

public class ShortestPath {

	public static void main(String[] args) {

		int[][] graph = new int[][] {
			{0,4,0,0,7},
			{4,0,1,2,0},
			{0,1,0,6,0},
			{0,2,6,0,0},
			{7,0,0,0,0}
			};
			
			ShortestPath path = new ShortestPath();
			path.dijkstra2(graph, 0);
	}
	

	
	

	private void dijkstra2(int[][] graph, int src) {
		int length = graph.length;
		boolean[] visited = new boolean[length];
		int[] distance = new int[length];
		distance[src] = src;
				
		for (int i = 1; i < length; i++) {
			distance[i] = Integer.MAX_VALUE;
		}
		
		for (int i = 0; i < length - 1; i++) {
			//find vertex with min distance
			int minVertex = findMinVertex(distance, visited);
			visited[minVertex] = true;
			// Explore neighbors
			for (int j = 0; j < length; j++) {
				if (graph[minVertex][j] !=0 && !visited[j] && distance[minVertex] != Integer.MAX_VALUE) {
					int newDist = distance[minVertex] + graph[minVertex][j];
					if (newDist < distance[j]) {
						distance[j] = newDist;
					}
				}
			}
		}
		
		//Print
		for (int i = 0; i < length; i++) {
			System.out.println(i + " " + distance[i]);
		}
	}

	private int findMinVertex(int[] distance, boolean[] visited) {
		int minVertex = -1;
		for (int i = 0; i < distance.length; i++) {
			if (!visited[i] && (minVertex == -1 || distance[i] < distance[minVertex])) {
				minVertex = i;
			}
		}
		return minVertex;
	}





	public void dijkstra(int[][] graph, int src){
		
		int[] insideGraphFirstArray = graph[src];
		int length = insideGraphFirstArray.length;
		int[] distance = new int [length];
		Boolean[] bool = new Boolean[length];
		
		for (int i = 0; i < length; i++) {
			distance[i] = Integer.MAX_VALUE;
			bool[i] = false;
		}
		
		distance[src] = src;
		for (int i = 0; i < length; i++) {
			int u = minDistance(distance, bool, length);
		}
	}
	
	public int minDistance(int[] distance, Boolean[] bool, int length) {
		int min = Integer.MAX_VALUE;
		int index = -1;
		
		for (int i = 0; i < length; i++) {
			if(bool[i] == false && distance[i] <= min) {
				
			}
		}
		
		return 0;
	}
}
