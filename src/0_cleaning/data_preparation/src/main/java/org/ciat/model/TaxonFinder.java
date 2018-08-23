package org.ciat.model;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.ciat.view.Executer;
import org.ciat.view.TaxaIO;
import org.json.JSONObject;

public class TaxonFinder {

	private static TaxonFinder instance = null;
	private Map<String, String> matchedTaxaKeys = new HashMap<String, String>();
	private Set<String> unmatchedTaxaKeys = new HashSet<String>();
	private final String rankField = "rank";
	private final String nameField = "scientificName";
	private final String keyField = "usageKey";

	public String fetchTaxonKey(String name) {

		// check first in the Map

		String result = matchedTaxaKeys.get(name);
		if (result != null) {
			return result;
		} else {
			if (unmatchedTaxaKeys.contains(name)) {
				return null;
			} else {
				result = "";
			}
		}

		// make connection

		URLConnection urlc;
		try {
			URL url = new URL("http://api.gbif.org/v1/species/match?kingdom=Plantae&name="
					+ URLEncoder.encode(name, "UTF-8") + "");

			urlc = url.openConnection();
			// use post mode
			urlc.setDoOutput(true);
			urlc.setAllowUserInteraction(false);

			// send query
			try (BufferedReader br = new BufferedReader(new InputStreamReader(urlc.getInputStream()))) {

				// get result
				String json = br.readLine();

				JSONObject object = new JSONObject(json);
				if (object.has(rankField) && object.has(keyField)) {
					String rank = object.get(rankField) + "";
					// check if the taxon is an specie or subspecie
					if (rank.contains("SPECIE") || rank.contains("VARIETY")) {
						String value = object.get(keyField) + "";
						value = value.replaceAll("\n", "");
						value = value.replaceAll("\r", "");
						result += value;
						// add result in the Map
						matchedTaxaKeys.put(name, value);
						return result;
					}
				}

			} catch (IOException e) {
				e.printStackTrace();
			} catch (Exception e) {
				e.printStackTrace();
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}

		unmatchedTaxaKeys.add(name);
		return null;
	}
	
	public String fetchTaxonName(String name) {

		String result = "" ;
		// make connection

		URLConnection urlc;
		try {
			name.replace('×', 'x');
			URL url = new URL("http://api.gbif.org/v1/species/match?kingdom=Plantae&name="
					+ URLEncoder.encode(name, "UTF-8") + "");

			urlc = url.openConnection();
			// use post mode
			urlc.setDoOutput(true);
			urlc.setAllowUserInteraction(false);

			// send query
			try (BufferedReader br = new BufferedReader(new InputStreamReader(urlc.getInputStream()))) {

				// get result
				String json = br.readLine();


				JSONObject object = new JSONObject(json);
				if (object.has(rankField) && object.has(nameField)) {
					String rank = object.get(rankField) + "";
					// check if the taxon is an specie or subspecie
					if (rank.contains("SPECIE") || rank.contains("VARIETY")) {
						String value =  object.get(keyField)+ org.ciat.control.Normalizer.STANDARD_SEPARATOR + object.get(nameField) + "";
						value = value.replaceAll("\n", "");
						value = value.replaceAll("\r", "");
						result += value;
						// add result in the Map
						return result;
					}
				}

			} catch (IOException e) {
				e.printStackTrace();
			} catch (Exception e) {
				e.printStackTrace();
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return null;
	}

	public Map<String, String> getMatchedTaxa() {
		return matchedTaxaKeys;
	}

	public Set<String> getUnmatchedTaxa() {
		return unmatchedTaxaKeys;
	}

	public static TaxonFinder getInstance() {
		if (instance == null) {
			
			instance = new TaxonFinder();
			
			File input = new File(Executer.prop.getProperty("file.taxa.matched"));
			if (input.exists()) {
				try (BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {
					
					String line = reader.readLine();
					while (line != null) {
						String[] values = line.split(TaxaIO.SEPARATOR);
						if (values.length == 2) {
							instance.matchedTaxaKeys.put(values[1], values[0]);
						}
						line = reader.readLine();
					}
					
				} catch (FileNotFoundException e) {
					System.out.println("File not found " + input.getAbsolutePath());
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			
			System.out.println(instance.matchedTaxaKeys.size()+" taxa imported");
		}


		return instance;
	}

	public void setMatchedTaxa(Map<String, String> matchedTaxa) {
		this.matchedTaxaKeys = matchedTaxa;
	}

}
