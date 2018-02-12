package org.ciat.model;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;

import java.util.Set;
import java.util.TreeSet;

import org.ciat.view.Executer;

public class TargetTaxa {

	private static TargetTaxa instance = null;
	private Set<String> speciesKeys = new TreeSet<String>();

	private TargetTaxa() {
		super();
		this.speciesKeys = loadTargetTaxa(new File(Executer.prop.getProperty("resource.targettaxa")));
	}

	public Set<String> getSpeciesKeys() {
		return speciesKeys;
	}

	public static TargetTaxa getInstance() {
		if (instance == null) {
			instance = new TargetTaxa();
		}
		return instance;
	}

	private  Set<String> loadTargetTaxa(File vocabularyFile) {
		Set<String> filters = new TreeSet<String>();
		try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(vocabularyFile)))) {

			String line = reader.readLine();
			while (line != null) {
				if (!line.isEmpty()&& Utils.isNumeric(line)) {
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
