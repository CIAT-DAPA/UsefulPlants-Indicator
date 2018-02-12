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

public class GenesysNormalizer extends Normalizer {

	private static final String INPUT_SEPARATOR = ",";

	public void process(File input, File output) {

		Set<String> taxonKeys = TargetTaxa.getInstance().getSpeciesKeys();

		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output, true)));
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

			/* header */
			String line = reader.readLine();
			if (colIndex.isEmpty()) {
				line = line.replaceAll(" ", "");
				colIndex = Utils.getColumnsIndex(line, INPUT_SEPARATOR);
			}

			/* progress bar */
			FileProgressBar bar = new FileProgressBar(input.length());
			/* */

			line = reader.readLine();
			while (line != null) {
				line = line.replaceAll("\"", "");
				line += SEPARATOR + " ";

				String[] values = line.split(INPUT_SEPARATOR);
				if (values.length >= colIndex.size()) {

					String taxonkey = "";
					taxonkey = TaxonFinder.getInstance().fetchTaxonInfo(values[colIndex.get("t.taxonName")]);
					Basis basis = Basis.G;


					if (taxonkey != null && taxonKeys.contains(taxonkey)) {
						boolean isUseful = isUseful(values);
						if (isUseful) {

							String result = normalize(values);
							writer.println(result);
						}
						CountExporter.getInstance().updateCounters(taxonkey, isUseful, null, basis);
					}
				}

				bar.update(line.length());

				line = reader.readLine();

			}

			bar.finish();

		} catch (FileNotFoundException e) {
			System.out.println("File not found " + input.getAbsolutePath());
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public boolean isUseful(String[] values) {

		if (Utils.iso3CountryCodeToIso2CountryCode(values[colIndex.get("a.orgCty")]) == null) {
			return false;
		}
		
		String lon = values[colIndex.get("decimallongitude")];
		String lat = values[colIndex.get("decimallatitude")];
		if (!Utils.areValidCoordinates(lat, lon)) {
			return false;
		}

		return true;
	}

	private String normalize(String[] values) {
		String lon = values[colIndex.get("decimallongitude")];
		String lat = values[colIndex.get("decimallatitude")];
		String country = Utils.iso3CountryCodeToIso2CountryCode(values[colIndex.get("a.orgCty")]);
		country = Utils.iso2CountryCodeToIso3CountryCode(country);
		String basis = Basis.G.toString();
		String taxonKey = TaxonFinder.getInstance().fetchTaxonInfo(values[colIndex.get("t.taxonName")]);
		String result = taxonKey + SEPARATOR + lon + SEPARATOR + lat + SEPARATOR + country + SEPARATOR + basis
				+ SEPARATOR + getDataSourceName();
		return result;
	}

	public DataSourceName getDataSourceName(String basisofrecord) {
		return DataSourceName.GENESYS;
	}

}
