package org.ciat.view;

import java.io.File;


import org.ciat.model.Utils;

public class App {

	public static void main(String[] args) {
		
		
		Utils.clearOutputDirectory(new File("outputs"));
		Executable app1 = new ExecNormalizer();
		app1.run();
		Executable app2 = new ExecNativeness();
		app2.run();
		Executable app3 = new ExecMaxentnisizer();
		app3.run();

	}

}
