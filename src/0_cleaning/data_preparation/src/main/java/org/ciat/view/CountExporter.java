package org.ciat.view;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.LinkedHashMap;
import java.util.Map;

import org.ciat.control.Normalizer;
import org.ciat.model.Basis;
import org.ciat.model.MapCounter;
import org.ciat.model.TargetTaxa;
import org.ciat.model.TaxonFinder;
import org.ciat.model.Utils;

public class CountExporter {
	
	private static CountExporter instance = null;

	private Map<String, MapCounter> counters;

	private CountExporter() {
		super();
		this.counters = new LinkedHashMap<String, MapCounter>();
		this.counters.put("totalRecords", new MapCounter());
		this.counters.put("totalUseful", new MapCounter());
		this.counters.put("totalGRecords", new MapCounter());
		this.counters.put("totalGUseful", new MapCounter());
		this.counters.put("totalHRecords", new MapCounter());
		this.counters.put("totalHUseful", new MapCounter());
		this.counters.put("totalPost1950", new MapCounter());
		this.counters.put("totalPre1950", new MapCounter());
		this.counters.put("totalNoDate", new MapCounter());
	}

	public Map<String, MapCounter> getCounters() {
		return counters;
	}

	public static CountExporter getInstance() {
		if (instance == null) {
			instance = new CountExporter();
		}
		return instance;
	}

	public void process() {
		exportSpeciesCounters();
		exportDatasetCounter();
	}

	private void exportDatasetCounter() {
		File output = new File(Executer.prop.getProperty("file.taxonfinder.summary"));
		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output)))) {
			writer.println("species.matched" + Normalizer.SEPARATOR + "species.unmatched");
			writer.println(TaxonFinder.getInstance().getMatchedTaxa().keySet().size() + Normalizer.SEPARATOR
					+ TaxonFinder.getInstance().getUnmatchedTaxa().size());

		} catch (FileNotFoundException e) {
			System.out.println("File not found " + output.getAbsolutePath());
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	private void exportSpeciesCounters() {

		// header of summary file
		File outputSummary = new File(Executer.prop.getProperty("file.counts.summary"));
		String header = "";

		for (String name : counters.keySet()) {
			header += name + Normalizer.SEPARATOR;
		}

		try (PrintWriter writerSummary = new PrintWriter(new BufferedWriter(new FileWriter(outputSummary)))) {
			writerSummary.println("taxonkey" + Normalizer.SEPARATOR + header);

			// for each target taxon in the list
			for (String taxonkey : TargetTaxa.getInstance().getSpeciesKeys()) {
				String countsLine = "";
				for (String name : counters.keySet()) {
					int count = 0;
					if (counters.get(name).get(taxonkey) != null) {
						count = counters.get(name).get(taxonkey);
					}
					countsLine += count + Normalizer.SEPARATOR;
				}

				File outputDir = new File(Executer.prop.getProperty("path.counts") + "/" + taxonkey + "/");
				if (!outputDir.exists()) {
					outputDir.mkdirs();
				} else {
					Utils.clearOutputDirectory(outputDir);
				}

				File output = new File(outputDir.getAbsolutePath() + "/counts.csv");

				try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output)))) {

					writer.println(header);
					writer.println(countsLine);
					writerSummary.println(taxonkey + Normalizer.SEPARATOR + countsLine);

				} catch (FileNotFoundException e) {
					System.out.println("File not found " + output.getAbsolutePath());
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		} catch (FileNotFoundException e) {
			System.out.println("File not found " + outputSummary.getAbsolutePath());
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public void updateCounters(String taxonkey, boolean useful, String year, Basis basis) {
		counters.get("totalRecords").increase(taxonkey);

		if (Utils.isNumeric(year)) {
			Integer yearNumber = Integer.parseInt(year);
			if (yearNumber >= Normalizer.YEAR) {
				counters.get("totalPost1950").increase(taxonkey);
			} else {
				counters.get("totalPre1950").increase(taxonkey);
			}
		} else {
			counters.get("totalNoDate").increase(taxonkey);
		}

		if (basis.equals(Basis.G)) {
			counters.get("totalGRecords").increase(taxonkey);
		} else {
			counters.get("totalHRecords").increase(taxonkey);
		}

		if (useful) {
			counters.get("totalUseful").increase(taxonkey);
			if (basis.equals(Basis.G)) {
				counters.get("totalGUseful").increase(taxonkey);
			} else {
				counters.get("totalHUseful").increase(taxonkey);
			}
		}

	}

}
