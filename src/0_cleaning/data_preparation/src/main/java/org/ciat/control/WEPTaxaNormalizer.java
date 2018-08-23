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
import java.util.TreeSet;

import org.ciat.model.TaxonFinder;



public class WEPTaxaNormalizer {

	public static void main(String[] args) {
		WEPTaxaNormalizer app = new WEPTaxaNormalizer();
		app.run();
	}
	
	
	private void run() {
		Set<String> targetTaxa = loadTargetTaxa(new File("inputs/wep.csv"));
		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(new File("outputs/wep_normalized.csv"))))){
			
			for(String taxa:targetTaxa){
				String info = TaxonFinder.getInstance().fetchTaxonName(taxa);
				writer.println(taxa +org.ciat.control.Normalizer.STANDARD_SEPARATOR + info );
			}
			
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}


	private  Set<String> loadTargetTaxa(File vocabularyFile) {
		Set<String> filters = new TreeSet<String>();
		try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(vocabularyFile)))) {

			String line = reader.readLine();
			while (line != null) {
				if (!line.isEmpty()) {
					filters.add(line);
				}
				line = reader.readLine();
			}

		} catch (FileNotFoundException e) {
			System.out.println("File not found " + vocabularyFile.getAbsolutePath());
		} catch (IOException e) {
			System.out.println("Cannot read " + vocabularyFile.getAbsolutePath());
		}
		return filters;
	}

}
