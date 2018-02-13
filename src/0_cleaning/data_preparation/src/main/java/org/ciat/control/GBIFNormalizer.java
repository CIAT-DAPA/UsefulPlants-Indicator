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

	@Override
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

					boolean isTargerTaxon = taxonkey != null && taxonKeys.contains(taxonkey);
					if (isTargerTaxon) {
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

	@Override
	public String normalize(String[] values) {
		String country = Utils.iso2CountryCodeToIso3CountryCode(values[colIndex.get("countrycode")]);
		String lon = values[colIndex.get("decimallongitude")];
		String lat = values[colIndex.get("decimallatitude")];
		Basis basis = getBasis(values[colIndex.get("basisofrecord")]);
		String source = getDataSourceName().toString();
		String taxonKey = values[colIndex.get("taxonkey")];
		String year = values[colIndex.get("year")];
		year = Utils.validateYear(year);
		String result = taxonKey + SEPARATOR + lon + SEPARATOR + lat + SEPARATOR + country + SEPARATOR + year
				+ SEPARATOR + basis + SEPARATOR + source;
		return result;

	}

	@Override
	public boolean isUseful(String[] values) {

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

		Basis basis = getBasis(values[colIndex.get("basisofrecord")]);
		String year = values[colIndex.get("year")];
		year = Utils.validateYear(year);
		if (!year.equals(Utils.NO_YEAR)) {
			if (basis.equals(Basis.H) && Integer.parseInt(year) < Normalizer.YEAR_MIN) {
				return false;
			}
		}

		return true;
	}

	@Override
	public Basis getBasis(String basisofrecord) {
		if (basisofrecord.toUpperCase().equals("LIVING_SPECIMEN")) {
			return Basis.G;
		}
		return Basis.H;
	}

	@Override
	public DataSourceName getDataSourceName() {
		return DataSourceName.GBIF;
	}

}
