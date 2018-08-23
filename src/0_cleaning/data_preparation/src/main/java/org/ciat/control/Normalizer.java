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
import java.util.Calendar;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;
import org.ciat.model.TargetTaxa;
import org.ciat.model.Utils;
import org.ciat.view.CountExporter;
import org.ciat.view.FileProgressBar;

public class Normalizer implements Normalizable {

	// column separator
	public static final String STANDARD_SEPARATOR = "\t";

	public static final int YEAR_MIN = 1950;
	public static final int YEAR_MAX = Calendar.getInstance().get(Calendar.YEAR);
	public static final String VALID = "";

	protected String[] values;

	// target columns
	protected static String[] colTarget = { "taxonkey", "decimallongitude", "decimallatitude", "countrycode", "year",
			"basis", "source" };

	// index of columns
	protected Map<String, Integer> colIndex = new LinkedHashMap<String, Integer>();

	@Override
	public void process(File input, File output, File trash) {

		Set<String> taxonKeys = TargetTaxa.getInstance().getSpeciesKeys();

		try (PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(output, true)));
				PrintWriter writerTrash = new PrintWriter(new BufferedWriter(new FileWriter(trash, true)));
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(new FileInputStream(input), "UTF-8"))) {

			/* header */
			String line = reader.readLine();
			colIndex = Utils.getColumnsIndex(line, getSpecificSeparator());
			/* */

			/* progress bar */
			FileProgressBar bar = new FileProgressBar(input.length());
			/* */

			line = reader.readLine();
			String past = "";

			while (line != null) {
				line += getSpecificSeparator();
				line = line.replace("\"", "");
				values = null;
				values = line.split(getSpecificSeparator());
				if (values.length >= colIndex.size()) {

					String taxonkey = getTaxonkey();
					Basis basis = getBasis();
					DataSourceName source = getDataSourceName();
					String year = getYear();

					boolean isTargetTaxon = taxonkey != null && taxonKeys.contains(taxonkey);
					if (isTargetTaxon) {
						String comments = validate();
						String normal = normalize();
						// if no comments it's because record is useful.
						boolean isUseful = comments.equals(VALID);
						if (isUseful) {

							if (!normal.equals(past)) {
								writer.println(normal);
								past = normal;
							}

						} else {
							// TODO activate this line again
							// writerTrash.println(normal + STANDARD_SEPARATOR +
							// validateResults);
						}

						// CENTROID VALIDATION
						// TODO move this validation to validate();
						comments += centroidValidation();
						if (comments.contains("CENTROID_COORDINATES;")) {
							writerTrash.println(normal + STANDARD_SEPARATOR + comments);
						}
						// end centroid validation

						CountExporter.getInstance().updateCounters(taxonkey, isUseful, year, basis, source,
								comments);
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
	public String normalize() {
		String country = getCountry();
		String lon = getDecimalLongitude();
		String lat = getDecimalLatitude();
		Basis basis = getBasis();
		String source = getDataSourceName().toString();
		String taxonKey = getTaxonkey();
		String year = getYear();
		String normal = taxonKey + STANDARD_SEPARATOR + lon + STANDARD_SEPARATOR + lat + STANDARD_SEPARATOR + country
				+ STANDARD_SEPARATOR + year + STANDARD_SEPARATOR + basis + STANDARD_SEPARATOR + source;
		return normal;

	}

	/*
	 * This method works with the premise that the record is useful until
	 * otherwise is proved
	 */
	@Override
	public String validate() {

		String result = VALID;

		// remove records without country
		String country = getCountry();
		if (country == null || country == Utils.NO_COUNTRY2 || country == Utils.NO_COUNTRY3) {
			result += "NO_COUNTRY;";
		}

		// remove records with invalid coordinates
		String lon = getDecimalLongitude();
		String lat = getDecimalLatitude();
		if (!Utils.areValidCoordinates(lat, lon)) {
			result += "NO_VALID_COORDINATES;";
		}

		// remove records of H before the 1950
		Basis basis = getBasis();
		String year = getYear();
		if (!year.equals(Utils.NO_YEAR)) {
			if (basis.equals(Basis.H) && Integer.parseInt(year) < Normalizer.YEAR_MIN) {
				result += "BEFORE_1950;";
			}
		}

		return result;
	}

	public String centroidValidation() {

		String result = VALID;

		if (Utils.areValidCoordinates(getDecimalLatitude(), getDecimalLongitude())) {

			// remove records with invalid coordinates
			Double lng = Double.parseDouble(getDecimalLongitude());
			Double lat = Double.parseDouble(getDecimalLatitude());

			if (Utils.areCentroidCoordinates(lat, lng)) {
				result += "CENTROID_COORDINATES;";
			}

		}
		return result;
	}

	@Override
	public Basis getBasis() {
		return null;
	}

	@Override
	public String getYear() {
		return Utils.NO_YEAR;
	}

	@Override
	public String getTaxonkey() {
		return null;
	}

	@Override
	public DataSourceName getDataSourceName() {
		return null;
	}

	@Override
	public String getDecimalLatitude() {
		return null;
	}

	@Override
	public String getDecimalLongitude() {
		return null;
	}

	@Override
	public String getCountry() {
		return Utils.NO_COUNTRY2;
	}

	public static String getStandardSeparator() {
		return STANDARD_SEPARATOR;
	}

	public static String getHeader() {
		String result = "";
		for (String field : colTarget) {
			result += field + STANDARD_SEPARATOR;
		}
		result = result.substring(0, result.length() - 1);
		return result;
	}

	@Override
	public String getSpecificSeparator() {
		return null;
	}

}
