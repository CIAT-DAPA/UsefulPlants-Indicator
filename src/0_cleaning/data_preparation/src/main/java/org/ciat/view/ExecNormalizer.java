package org.ciat.view;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import org.ciat.control.CWRDBNormalizer;
import org.ciat.control.GBIFNormalizer;
import org.ciat.control.GenesysNormalizer;
import org.ciat.control.Normalizable;
import org.ciat.control.Normalizer;
import org.ciat.model.TaxonFinder;
import org.ciat.model.Utils;

public class ExecNormalizer extends Executer {

	public static void main(String[] args) {
		Executable app = new ExecNormalizer();
		app.run();
	}

	public void run() {

		log("Starting process");

		Utils.createOutputDirectory(new File("outputs"));
		Utils.createOutputDirectory(new File("temp"));
		File normalized = new File(Executer.prop.getProperty("file.normalized"));
		File trash = new File(Executer.prop.getProperty("file.data.trash"));
		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(normalized)))) {
			String header = Normalizer.getHeader();
			writer.println(header);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		// Reduce and normalize
		log("Normalizing GBIF data");
		Normalizable gbifNormalizer = new GBIFNormalizer();
		gbifNormalizer.process(new File(Executer.prop.getProperty("data.gbif")), normalized, trash);
		System.gc();

		// filter Genesys data
		log("Normalizing Genesys data");
		Normalizable genesysNormalizer = new GenesysNormalizer();
		genesysNormalizer.process(new File(Executer.prop.getProperty("data.genesys")), normalized, trash);
		System.gc();

		// filter CWR data
		log("Normalizing CWR data");
		Normalizable cwrdbNormalizer = new CWRDBNormalizer();
		cwrdbNormalizer.process(new File(Executer.prop.getProperty("data.cwr")), normalized, trash);
		System.gc();

		// export counters
		log("Exporting counters");
		CountExporter.getInstance().process();
		System.gc();
		
		// export counters
		log("Exporting taxa");
		TaxaIO.exportTaxaMatched(TaxonFinder.getInstance().getMatchedTaxa(),new File(Executer.prop.getProperty("file.taxa.matched")));
		TaxaIO.exportTaxaUnmatched(TaxonFinder.getInstance().getUnmatchedTaxa(),new File(Executer.prop.getProperty("file.taxa.unmatched")));
		
		TaxonFinder.getInstance().getUnmatchedTaxa();
		System.gc();
		

	}

}
