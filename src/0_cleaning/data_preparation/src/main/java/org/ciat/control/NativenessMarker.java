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
import java.util.Map;
import java.util.TreeMap;

import org.ciat.model.Nativeness;
import org.ciat.model.TaxonNativeness;
import org.ciat.model.Utils;
import org.ciat.view.Executer;
import org.ciat.view.FileProgressBar;

public class NativenessMarker {

	private Map<String, Integer> colIndex;
	private Map<String, Integer> natienessIndex;
	private Map<Integer, TaxonNativeness> taxaCWR;

	public void process(File input, File output) {

		File taxaFile = new File(Executer.prop.getProperty("resource.nativeness"));
		taxaCWR = loadTargetTaxaNativeness(taxaFile);

		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output, true)));
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

			/* header */
			String line = reader.readLine();
			colIndex = Utils.getColumnsIndex(line, Normalizer.STANDARD_SEPARATOR);
			/* */

			/* progress bar */
			FileProgressBar bar = new FileProgressBar(input.length());
			/* */

			line = reader.readLine();
			while (line != null) {
				line += Normalizer.STANDARD_SEPARATOR;
				String[] values = line.split(Normalizer.STANDARD_SEPARATOR);
				if (values.length == colIndex.size() && isNative(values)) {
					line += Nativeness.N;
				} else {
					line += Nativeness.C;
				}
				writer.println(line);

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

	private boolean isNative(String[] values) {

		/* check if it's a target taxon */
		if (colIndex.get("taxonkey") != null && colIndex.get("countrycode") != null) {
			String country = values[colIndex.get("countrycode")];
			Integer taxonKey = Integer.parseInt(values[colIndex.get("taxonkey")]);
			if (taxaCWR.containsKey(taxonKey)) {
				/* check if taxon is native in that country */
				if (taxaCWR.get(taxonKey).getNativeCountries().contains(country)) {
					return true;
				}
			}
		}

		return false;
	}

	private Map<Integer, TaxonNativeness> loadTargetTaxaNativeness(File vocabularyFile) {
		Map<Integer, TaxonNativeness> CWRs = new TreeMap<Integer, TaxonNativeness>();
		try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(vocabularyFile)))) {

			String line = reader.readLine();
			natienessIndex = Utils.getColumnsIndex(line, Normalizer.STANDARD_SEPARATOR);
			line = reader.readLine();
			while (line != null) {
				if (!line.isEmpty()) {
					String[] values = line.split(Normalizer.STANDARD_SEPARATOR);
					if (values.length > 2) {
						if (Utils.isNumeric(values[natienessIndex.get("taxonkey")])) {
							Integer taxonKey = Integer.parseInt(values[natienessIndex.get("taxonkey")]);
							String country = values[natienessIndex.get("ISO3")];
							if (CWRs.containsKey(taxonKey)) {
								CWRs.get(taxonKey).getNativeCountries().add(country);
							} else {
								TaxonNativeness newCWR = new TaxonNativeness(taxonKey);
								newCWR.getNativeCountries().add(country);
								CWRs.put(taxonKey, newCWR);
							}
						}
					}

				}
				line = reader.readLine();
			}

		} catch (FileNotFoundException e) {
			System.out.println("File not found " + vocabularyFile.getAbsolutePath());
		} catch (IOException e) {
			System.out.println("Cannot read " + vocabularyFile.getAbsolutePath());
		}

		return CWRs;
	}

}
