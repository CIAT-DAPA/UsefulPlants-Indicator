package org.ciat.control;

import java.io.File;
import java.util.LinkedHashMap;
import java.util.Map;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;

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



	@Override
	public String normalize(String line) {
		return line;
	}
}
