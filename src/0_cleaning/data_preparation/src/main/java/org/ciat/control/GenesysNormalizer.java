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

	private static final String SPECIFIC_SEPARATOR = ",";

	@Override
	public void process(File input, File output) {

		Set<String> taxonKeys = TargetTaxa.getInstance().getSpeciesKeys();

		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output, true)));
				PrintWriter writerTrash = new PrintWriter(new BufferedWriter(new FileWriter(output.getParentFile()+File.separator+"trash.csv", true)));
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

			/* header */
			String line = reader.readLine();
			if (colIndex.isEmpty()) {
				line = line.replaceAll(" ", "");
				colIndex = Utils.getColumnsIndex(line, SPECIFIC_SEPARATOR);
			}

			/* progress bar */
			FileProgressBar bar = new FileProgressBar(input.length());
			/* */
			
			line = reader.readLine();
			while (line != null) {
				line = line.replaceAll("\"", "");
				line += STANDARD_SEPARATOR + " ";

				String[] values = line.split(SPECIFIC_SEPARATOR);
				if (values.length >= colIndex.size()) {

					String taxonkey = getTaxonkey();
					Basis basis = getBasis();
					DataSourceName source = getDataSourceName();
					String year = getYear();
					boolean isTargerTaxon = taxonkey != null && taxonKeys.contains(taxonkey);
					if (isTargerTaxon) {
						boolean isUseful = isUseful();
						if (isUseful) {

							String result = normalize();
							writer.println(result);
						}
						CountExporter.getInstance().updateCounters(taxonkey, isUseful, year, basis, source);
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

	@Override
	public boolean isUseful() {

		if (Utils.iso3CountryCodeToIso2CountryCode(values[colIndex.get("a.orgCty")]) == null) {
			return false;
		}

		String lon = values[colIndex.get("g.longitude")];
		String lat = values[colIndex.get("g.latitude")];
		if (!Utils.areValidCoordinates(lat, lon)) {
			return false;
		}

		return true;
	}

	@Override
	public String normalize() {
		String lon = values[colIndex.get("g.longitude")];
		String lat = values[colIndex.get("g.latitude")];
		String country = Utils.iso3CountryCodeToIso2CountryCode(values[colIndex.get("a.orgCty")]);
		country = Utils.iso2CountryCodeToIso3CountryCode(country);
		String basis = Basis.G.toString();
		String source = getDataSourceName().toString();
		String taxonKey = TaxonFinder.getInstance().fetchTaxonInfo(values[colIndex.get("t.taxonName")]);
		String year = values[colIndex.get("a.acqDate")];
		year = Utils.validateYear(year);
		String result = taxonKey + STANDARD_SEPARATOR + lon + STANDARD_SEPARATOR + lat + STANDARD_SEPARATOR + country + STANDARD_SEPARATOR + year
				+ STANDARD_SEPARATOR + basis + STANDARD_SEPARATOR + source;
		return result;
	}

	@Override
	public DataSourceName getDataSourceName() {
		return DataSourceName.GENESYS;
	}

	@Override
	public Basis getBasis() {
		return Basis.G;
	}

	@Override
	public String getYear() {
		String year = values[colIndex.get("a.acqDate")];
		if (year.length() > 3) {
			year = year.substring(0, 4);
		}
		return super.getYear();
	}

	@Override
	public String getTaxonkey() {
		return TaxonFinder.getInstance().fetchTaxonInfo(values[colIndex.get("t.taxonName")]);
	}
	
	

}
