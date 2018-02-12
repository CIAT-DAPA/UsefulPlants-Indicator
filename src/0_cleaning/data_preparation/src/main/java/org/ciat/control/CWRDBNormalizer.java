package org.ciat.control;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.Set;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;
import org.ciat.model.TargetTaxa;
import org.ciat.model.TaxonFinder;
import org.ciat.model.Utils;
import org.ciat.view.CountExporter;
import org.ciat.view.FileProgressBar;

public class CWRDBNormalizer extends Normalizer {

	private static final String INPUT_SEPARATOR = "\\|";

	public void process(File input, File output) {
		Set<String> taxonKeys = TargetTaxa.getInstance().getSpeciesKeys();

		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output, true)));
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

			/* header */
			String line = reader.readLine();
			if (colIndex.isEmpty()) {
				colIndex = Utils.getColumnsIndex(line, INPUT_SEPARATOR);
			}
			/* */

			/* progress bar */
			FileProgressBar bar = new FileProgressBar(input.length());
			/* */

			line = reader.readLine();
			String past = "";

			while (line != null) {

				line = line.replace("\"", "");
				String[] values = line.split(INPUT_SEPARATOR);
				if (values.length >= colIndex.size()) {

					String taxonkey = TaxonFinder.getInstance().fetchTaxonInfo(values[colIndex.get("taxon_final")]);
					Basis basis = getBasis(values[colIndex.get("source")]);
					String year = values[colIndex.get("colldate")];
					if (year.length() > 3) {
						year = year.substring(0, 4);
					}

					if (taxonkey != null && taxonKeys.contains(taxonkey)) {
						boolean isUseful = isUseful(values);
						if (isUseful) {

							String normal = normalize(values);
							if (normal != null && !normal.equals(past)) {
								writer.println(normal);
								past = normal;
							}
						}

						CountExporter.getInstance().updateCounters(taxonkey, isUseful, year, basis);
					}
				}
				/* show progress */
				bar.update(line.length());
				/* */

				line = reader.readLine();

			}
			bar.finish();

		} catch (FileNotFoundException e) {
			System.out.println("File not found " + input.getAbsolutePath());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private String normalize(String[] values) {
		String lon = values[colIndex.get("final_lon")];
		String lat = values[colIndex.get("final_lat")];
		String country = values[colIndex.get("final_iso2")];
		country = Utils.iso2CountryCodeToIso3CountryCode(country);
		Basis basis = getBasis(values[colIndex.get("source")]);
		String taxonKey = TaxonFinder.getInstance().fetchTaxonInfo(values[colIndex.get("taxon_final")]);
		String result = taxonKey + SEPARATOR + lon + SEPARATOR + lat + SEPARATOR + country + SEPARATOR + basis
				+ SEPARATOR + getDataSourceName();
		return result;
	}

	public boolean isUseful(String[] values) {

		if (!(values[colIndex.get("coord_source")].equals("original")
				|| values[colIndex.get("coord_source")].equals("georef"))) {
			return false;
		}

		if (!(values[colIndex.get("source")].equals("G") || values[colIndex.get("source")].equals("H"))) {
			return false;
		}

		String date = values[colIndex.get("colldate")];
		if (date.length() > 3) {
			date = date.substring(0, 4);
			if (Utils.isNumeric(date)) {
				int year = Integer.parseInt(date);
				if (year < Normalizer.YEAR) {
					return false;
				}
			}
		}

		String country = values[colIndex.get("final_iso2")];
		country = Utils.iso2CountryCodeToIso3CountryCode(country);
		if (country == null) {
			return false;
		}

		String lon = values[colIndex.get("final_lon")];
		String lat = values[colIndex.get("final_lat")];

		if (!Utils.areValidCoordinates(lat, lon)) {
			return false;
		}

		return true;

	}

	public DataSourceName getDataSourceName() {
		return DataSourceName.CWRDB;
	}

	public Basis getBasis(String basisofrecord) {
		if (basisofrecord.toUpperCase().equals("G")) {
			return Basis.G;
		}
		return Basis.H;
	}

}
