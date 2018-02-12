package org.ciat.control;

import java.io.File;
import java.util.Calendar;
import java.util.LinkedHashMap;
import java.util.Map;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;
import org.ciat.model.Utils;

public class Normalizer implements Normalizable {
	
	// column separator
	public static final String SEPARATOR = "\t";
	// temporal coverage
	public static final int YEAR_MIN = 1950;
	public static final int YEAR_MAX = Calendar.getInstance().get(Calendar.YEAR);
	// target columns
	public static String[] colTarget = { "taxonkey", "decimallongitude", "decimallatitude", "countrycode", "basis",
			"source" };

	// index of columns
	protected Map<String, Integer> colIndex = new LinkedHashMap<String, Integer>();

	public void process(File file, File normalized) {

	}
	
	public static String getHeader() {
		String result = "";
		for (String field : colTarget) {
			result += field + SEPARATOR;
		}
		result = result.substring(0, result.length() - 1);
		return result;
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

	public boolean isInTemporalScale(String year) {
		if (year == null) {
			/* unknow years are in */
			return true;
		}
		if (Utils.isNumeric(year)) {
			int y = Integer.parseInt(year);
			/* outside the range are out*/
			if (y < YEAR_MIN || y > YEAR_MAX) {
				return false;
			}
		}
		/*non numerics are in*/
		return true;

	}

	@Override
	public String normalize(String line) {
		return line;
	}
}
