package org.ciat.view;

/**
 * @author c00kiemon5ter
 * @author danipilze Ascii progress meter. modified to show progress on
 *         processing files <br />
 * 		<br />
 *         100% ################################################## |
 */
public class FileProgressBar {
	private StringBuilder progress;

	private long fileLenght;
	private int exp;
	private int dimensionality;
	private int total;
	private long done;
	private int lineNumber;

	/**
	 * initialize progress bar properties.
	 */
	public FileProgressBar(long fileLenght) {
		this.fileLenght = fileLenght;
		init();
	}

	/**
	 * called whenever the progress bar needs to be updated. that is whenever
	 * progress was made.
	 *
	 * @param done
	 *            an int representing the work done so far
	 * @param total
	 *            an int representing the total work
	 */
	private void update(int done, int total) {
		char[] workchars = { '|', '/', '-', '\\' };
		String format = "\r%3d%% %s %c";
		total = total < 1 ? 1 : total;

		int percent = 100;
		if (done != total) {
			percent = (++done * 100) / total;
		}
		int extrachars = (percent / 2) - this.progress.length();

		while (extrachars-- > 0) {
			progress.append('#');
		}

		System.out.printf(format, percent, progress, workchars[done % workchars.length]);

		if (done == total) {
			System.out.flush();
			System.out.println();
		}
	}

	public void update(int lineLenght) {
		/* show progress */
		this.done += lineLenght;
		if (++this.lineNumber % this.dimensionality == 0) {
			this.update(Math.toIntExact(this.done / this.dimensionality), this.total);
		}
		/* */
	}

	public void finish() {
		/* show progress */
		this.update(this.total, this.total);
		/* */
	}

	private void init() {
		this.progress = new StringBuilder(60);
		this.exp = (int) Math.ceil((fileLenght + "").length()) + 1;
		this.dimensionality = (int) Math.pow(2, exp);
		this.total = Math.toIntExact(fileLenght / dimensionality);
		this.done = 0;
		this.lineNumber = 0;
		System.out.println("Processing " + fileLenght / 1024 + "KBs, updating progress each " + dimensionality + "KBs");
	}
}