package org.ciat.view;

import java.io.File;

import org.ciat.control.Maxentnisizer;

public class ExecMaxentnisizer extends Executer {

	public static void main(String[] args) {
		Executable app = new ExecMaxentnisizer();
		app.run();
	}

	public void run() {

		// convert to Maxent format
		log("Exporting data to Maxent");
		File nativenessed = new File(Executer.prop.getProperty("file.native"));
		Maxentnisizer maxentnisizer = new Maxentnisizer();
		maxentnisizer.process(nativenessed);
		System.gc();

	}

}
