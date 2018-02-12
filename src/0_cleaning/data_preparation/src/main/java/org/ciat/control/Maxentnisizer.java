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
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import org.ciat.model.Utils;
import org.ciat.view.Executer;
import org.ciat.view.FileProgressBar;

public class Maxentnisizer {

	// index of columns
	private Map<String, Integer> colIndex = new LinkedHashMap<String, Integer>();
	// target columns
	private String[] colTarget = { "decimallongitude", "decimallatitude", "countrycode", "basis","origin" };

	private static final String SEPARATOR = "\t";

	/** @return output file */
	public void process(File input) {

		File outputDir = new File(Executer.prop.getProperty("path.raw"));
		if (!outputDir.exists()) {
			outputDir.mkdirs();
		} else {
			Utils.clearOutputDirectory(outputDir);
		}

		try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

			/* header */
			String line = reader.readLine();
			if (colIndex.isEmpty()) {
				colIndex = Utils.getColumnsIndex(line, SEPARATOR);
			}

			/* progress bar */
			FileProgressBar bar = new FileProgressBar(input.length());
			/* */

			Map<String, PrintWriter> writers = new TreeMap<String, PrintWriter>();
			Map<String, Set<String>> coords = new TreeMap<String, Set<String>>();

			line = reader.readLine();
			while (line != null) {
				line += SEPARATOR + " ";

				String[] values = line.split(SEPARATOR);

				String taxon = values[colIndex.get("taxonkey")];
				File output = new File(outputDir.getAbsolutePath() + "/" + taxon + ".csv");

				if (!writers.keySet().contains(taxon)) {
					writers.put(taxon, new PrintWriter(new BufferedWriter(new FileWriter(output, true))));
					coords.put(taxon, new TreeSet<String>());
				}

				// get only target values to print
				String coord = getTargetValues(values);
				// include them only if they are new to avoid duplicates
				if (!coords.get(taxon).contains(coord)) {
					writers.get(taxon).println(coord);
					coords.get(taxon).add(coord);
				}

				/* show progress */
				bar.update(line.length());
				/* */
				line = reader.readLine();

			}
			bar.finish();

			for (String key : writers.keySet()) {
				writers.get(key).flush();
				writers.get(key).close();
			}

		} catch (FileNotFoundException e) {
			System.out.println("File not found " + input.getAbsolutePath());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}



	/** Getting only targeted values **/
	private String getTargetValues(String[] values) {
		String output = "";
		for (String col : colTarget) {
			if (values.length > colIndex.size() && colIndex.get(col) != null) {
				output += values[colIndex.get(col)];
				output += SEPARATOR;
			}
		}
		output = output.substring(0, output.length());
		return output;
	}

}
