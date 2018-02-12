package org.ciat.control;

import java.io.File;
import java.util.Calendar;
import java.util.LinkedHashMap;
import java.util.Map;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;

public class Normalizer implements Normalizable {

	// column separator
	protected static final String SEPARATOR = "\t";
	
	public static final int YEAR_MIN = 1950;
	public static final int YEAR_MAX = Calendar.getInstance().get(Calendar.YEAR);
	public static final String NO_YEAR = "";

	// target columns
	protected static String[] colTarget = { "taxonkey", "decimallongitude", "decimallatitude", "countrycode", "year",
			"basis", "source" };

	// index of columns
	protected Map<String, Integer> colIndex = new LinkedHashMap<String, Integer>();

	@Override
	public void process(File file, File normalized) {

	}

	@Override
	public Basis getBasis(String basisofrecord) {
		return null;
	}

	@Override
	public DataSourceName getDataSourceName() {
		return null;
	}

	@Override
	public boolean isUseful(String[] values) {
		return false;
	}

	@Override
	public String normalize(String[] values) {
		return null;
	}

	public static String getSeparator() {
		return SEPARATOR;
	}

	public static String getHeader() {
		String result = "";
		for (String field : colTarget) {
			result += field + SEPARATOR;
		}
		result = result.substring(0, result.length() - 1);
		return result;
	}
}
