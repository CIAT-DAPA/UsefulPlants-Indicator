package org.ciat.model;

import org.ciat.view.Executer;

import com.javadocmd.simplelatlng.LatLng;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.DecimalFormat;
import java.util.LinkedHashSet;
import java.util.Set;

public class CentroidFinder {

	private static CentroidFinder instance = null;
	private Set<LatLng> centroids = new LinkedHashSet<LatLng>();
	private final DecimalFormat DFORMAT = new DecimalFormat("#.###");

	public boolean areCentroid(double lat, double lng) {

		LatLng point = new LatLng(Double.parseDouble(DFORMAT.format(lat)), Double.parseDouble(DFORMAT.format(lng)));

		return centroids.contains(point);

	}

	public Set<LatLng> getMatchedTaxa() {
		return centroids;
	}

	public static CentroidFinder getInstance() {
		if (instance == null) {

			instance = new CentroidFinder();

			File input = new File(Executer.prop.getProperty("resource.centroids"));
			if (input.exists()) {
				try (BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

					String line = reader.readLine();
					while (line != null) {
						String[] values = line.split(",");
						double lat = Double.parseDouble(values[4]);
						double lng = Double.parseDouble(values[5]);
						if (values.length > 4) {
							instance.centroids.add(new LatLng(Double.parseDouble(instance.DFORMAT.format(lat)),
									Double.parseDouble(instance.DFORMAT.format(lng))));
						}
						line = reader.readLine();
					}

				} catch (FileNotFoundException e) {
					System.out.println("File not found " + input.getAbsolutePath());
				} catch (IOException e) {
					e.printStackTrace();
				}
			}

			System.out.println(instance.centroids.size() + " unique centroids imported");
		}

		return instance;
	}

	public void setMatchedTaxa(Set<LatLng> centroids) {
		this.centroids = centroids;
	}

}
