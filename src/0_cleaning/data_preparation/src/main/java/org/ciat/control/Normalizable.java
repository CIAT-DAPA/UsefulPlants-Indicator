package org.ciat.control;

import java.io.File;
import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;

public interface Normalizable {
	
	// output separator
	public static final String SEPARATOR = "\t";
	// year for considered records
	public static final int YEAR = 1950;
	// target columns
	public String[] colTarget = { "taxonkey", "decimallongitude", "decimallatitude", "countrycode", "basis",
			"source" };



	public static String getHeader() {
		String result = "";
		for (String field : colTarget) {
			result += field + SEPARATOR;
		}
		result = result.substring(0, result.length() - 1);
		return result;
	}

	public Basis getBasis(String basisofrecord);

	public DataSourceName getDataSourceName();

	public boolean isUseful(String[] values);

	public void process(File input, File output);

	public String normalize(String line);

}
