package org.ciat.model;

import org.ciat.view.Executer;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.List;


public class CentroidFinder {

	private static CentroidFinder instance = null;
	private  List<String> centroids = new LinkedList<String>();

	public boolean isCentroid(double lat, double lon) {

		// check first in the Map

		boolean result = true;

		return false;
	}

	public List<String> getMatchedTaxa() {
		return centroids;
	}

	public static CentroidFinder getInstance() {
		if (instance == null) {

			instance = new CentroidFinder();

			File input = new File(Executer.prop.getProperty("file.centroids"));
			if (input.exists()) {
				try (BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

					String line = reader.readLine();
					while (line != null) {
						String[] values = line.split(",");
						if (values.length == 2) {
							instance.centroids.add(""/*new Point(values[0], values[1])*/);
						}
						line = reader.readLine();
					}

				} catch (FileNotFoundException e) {
					System.out.println("File not found " + input.getAbsolutePath());
				} catch (IOException e) {
					e.printStackTrace();
				}
			}

			System.out.println(instance.centroids.length() + " centroids imported");
		}

		return instance;
	}

	public void setMatchedTaxa(List<String> centroids) {
		this.centroids = centroids;
	}

}
