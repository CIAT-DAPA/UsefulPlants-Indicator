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
import java.util.LinkedHashSet;
import java.util.Set;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;
import org.ciat.model.TargetTaxa;
import org.ciat.model.Utils;
import org.ciat.view.CountExporter;
import org.ciat.view.FileProgressBar;

public class GBIFNormalizer extends Normalizer {

	/** @return output file */
	public void process(File input, File output) {

		Set<String> taxonKeys = TargetTaxa.getInstance().getSpeciesKeys();

		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output, true)));
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

			/* header */
			String line = reader.readLine();
			colIndex = Utils.getColumnsIndex(line, SEPARATOR);
			/* */

			/* progress bar */
			FileProgressBar bar = new FileProgressBar(input.length());
			/* */

			line = reader.readLine();
			while (line != null) {
				line += SEPARATOR + " ";
				String[] values = line.split(SEPARATOR);
				if (values.length >= colIndex.size()) {

					String taxonkey = values[colIndex.get("taxonkey")];
					Basis basis = getBasis(values[colIndex.get("basisofrecord")]);
					String year = values[colIndex.get("year")];

					if (taxonkey != null && taxonKeys.contains(taxonkey)) {
						boolean isUseful = isUseful(values);
						if (isUseful) {

							String result = normalize(values);
							writer.println(result);
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
		String country = Utils.iso2CountryCodeToIso3CountryCode(values[colIndex.get("countrycode")]);
		String result = values[colIndex.get("taxonkey")] + SEPARATOR + values[colIndex.get("decimallongitude")]
				+ SEPARATOR + values[colIndex.get("decimallatitude")] + SEPARATOR + country + SEPARATOR
				+ getBasis(values[colIndex.get("basisofrecord")]) + SEPARATOR + getDataSourceName();
		return result;
	}

	public boolean isUseful(String[] values) {

		// excluding CWR dataset
		if (colIndex.get("year") != null && Utils.isNumeric(values[colIndex.get("year")])) {
			int year = Integer.parseInt(values[colIndex.get("year")]);
			if (year < Normalizer.YEAR)
				return false;
		}

		if (colIndex.get("datasetkey") != null
				&& values[colIndex.get("datasetkey")].contains("07044577-bd82-4089-9f3a-f4a9d2170b2e")) {
			return false;
		}

		// only allow species and subspecies
		if (colIndex.get("taxonrank") != null) {
			if (!values[colIndex.get("taxonrank")].contains("SPECIES")) {
				return false;
			}
		}

		String country = Utils.iso2CountryCodeToIso3CountryCode(values[colIndex.get("countrycode")]);
		if (country == null) {
			return false;
		}

		Set<String> issues = new LinkedHashSet<>();
		issues.add("COORDINATE_OUT_OF_RANGE");
		issues.add("COUNTRY_COORDINATE_MISMATCH");
		issues.add("ZERO_COORDINATE");
		for (String issue : issues) {
			if (colIndex.get("issue") != null && values[colIndex.get("issue")].contains(issue)) {
				return false;
			}
		}

		if (!Utils.areValidCoordinates(values[colIndex.get("decimallatitude")],
				values[colIndex.get("decimallongitude")])) {
			return false;
		}

		return true;
	}

	public Basis getBasis(String basisofrecord) {
		if (basisofrecord.toUpperCase().equals("LIVING_SPECIMEN")) {
			return Basis.G;
		}
		return Basis.H;
	}

	public DataSourceName getDataSourceName() {
		return DataSourceName.GBIF;
	}

}
