package org.ciat.control;

import java.io.File;
import java.util.LinkedHashMap;
import java.util.Map;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;
import org.ciat.model.Utils;

public class Normalizer implements Normalizable {

	// index of columns
	protected Map<String, Integer> colIndex = new LinkedHashMap<String, Integer>();

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

	public boolean isInTemporalScale(String year) {
		if (year == null) {
			/* unknow years are in */
			return true;
		}
		if (Utils.isNumeric(year)) {
			int y = Integer.parseInt(year);
			/* outside the range are out*/
			if (y < Normalizable.YEAR_MIN || y > Normalizable.YEAR_MAX) {
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
