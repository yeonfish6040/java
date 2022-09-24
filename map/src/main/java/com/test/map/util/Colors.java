package com.test.map.util;

import java.util.Random;

public class Colors {
	
	public static String BLACK = "\033[30m";
	public static String RED = "\033[31m";
	public static String GREEN = "\033[32m";
	public static String YELLOW = "\033[33m";
	public static String BLUE = "\033[34m";
	public static String MAGENTA = "\033[35m";
	public static String CYAN = "\033[36m";
	public static String WHITE = "\033[37m";
	
	public static String B_BLACK = "\033[100m";
	public static String B_RED = "\033[101m";
	public static String B_GREEN = "\033[102m";
	public static String B_YELLOW = "\033[103m";
	public static String B_BLUE = "\033[104m";
	public static String B_MAGENTA = "\033[105m";
	public static String B_CYAN = "\033[106m";
	public static String B_WHILE = "\033[107m";
	
	public static String END = "\033[0m";
	
	public static String R_COLOR() {
		Random rd = new Random();
		int color = rd.nextInt(256);
		String rc = "\033[38;5;"+color+"m";
		return rc;
	}
	
	public static void p(String title, int count) {
		String star = "";
		for(int i=0;i<count;i++) {
			star += "*";
		}
		System.out.println(star);
		Random rd = new Random();
		int color = rd.nextInt(256);
		System.out.println("\033[38;5;"+color+"m"+title+END);
		System.out.println(star);
		
	}
//	Colors(){
//		System.out.println("누가 나 호출했냐");
//	}

}
