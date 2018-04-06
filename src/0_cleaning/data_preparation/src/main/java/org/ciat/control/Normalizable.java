package org.ciat.control;

import java.io.File;

import org.ciat.model.Basis;
import org.ciat.model.DataSourceName;

public interface Normalizable {
	
	public Basis getBasis();
	
	public String getYear();
	
	public String getTaxonkey();

	public DataSourceName getDataSourceName();

	public boolean isUseful();

	public void process(File input, File output);

	public String normalize();

}
