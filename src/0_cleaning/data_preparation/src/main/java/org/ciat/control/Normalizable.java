package org.ciat.control;

import java.io.File;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;

public interface Normalizable {
	
	public Basis getBasis(String basisofrecord);

	public DataSourceName getDataSourceName();

	public boolean isUseful(String[] values);

	public void process(File input, File output);

	public String normalize(String line);

}
