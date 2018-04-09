package org.ciat.view;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.Set;

public class TaxaIO {

	public static final String SEPARATOR = "\t";

	public static void exportTaxaMatched(Map<String, String> matchedTaxa, File output) {
		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output)))) {

			for (String name : matchedTaxa.keySet()) {
				writer.println(matchedTaxa.get(name) + SEPARATOR + name);
			}

		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public static void exportTaxaUnmatched(Set<String> set, File output) {
		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output)))) {

			for (String name : set) {
				writer.println(name);
			}

		} catch (IOException e) {
			e.printStackTrace();
		}

	}

}
