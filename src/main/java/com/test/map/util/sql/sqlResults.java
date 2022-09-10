package com.test.map.util.sql;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Arrays;
import java.util.ArrayList;
import java.awt.Font;
import java.awt.font.FontRenderContext;
import java.awt.geom.AffineTransform;

public class sqlResults {
	protected String[][] data;
	protected int column_count;
	protected int table_nm;
	sqlResults(String[][] data, int column_count) {
		this.data = data;
		this.column_count = column_count;
	}
	
	public boolean isEmpty() {
		if(getRowCount() == 1) {
			return false;
		}else {
			return true;
		}
	}
	
	public String[][] get() {
		return data;
	}
	
	public List<List<String>> getList() {
		List<List<String>> rows = new ArrayList<List<String>>();
		for(String[] e: data) {
			rows.add(Arrays.asList(e));
		}
		return rows;
	}
	
	public int getRowCount() {
		return data.length;
	}
	
	public int getColCount() {
		return column_count;
	}
	
	public String[] split(String spChar) {
		String[] result = new String[data.length];
		int i = 0;
		for(String[] e:data) {
			String str = "";
			for(String e2:e) {
				if (str == "") str += e2;
				else str += spChar+e2;
			}
			result[i] = str;
			i++;
		}
		return result;
	}
	
	public String[][] findCol(int col, String text, Boolean egnoreCase) {
		List<String[]> finded = new ArrayList<String[]>();
		if (egnoreCase) {
			for(String[] s:data) {
				if(s[col].equalsIgnoreCase(text))
					finded.add(s);
			}
		}else {
			for(String[] s:data) {
				if(s[col].equals(text))
					finded.add(s);
			}
		}
		return finded.toArray(new String[getColCount()][getRowCount()]);
	}
	
	public String getTable() {
		StringBuffer showTable = new StringBuffer();
		int[] maxLen = new int[getColCount()];
		int i = 0;
		for(String e:data[0]) {
			maxLen[i] = getWidth(e);
		}
		int j = 0;
		for(String[] e:data) {
			j = 0;
			for(String e2:e) {
				if(e2 == "" || e2 == null) e2 = "null";
				
				if(getWidth(e2) > maxLen[j])
					maxLen[j] = getWidth(e2);
				j++;
			}
		}
		i = 0;
		for(String[] e:data) {
			j = 0;
			for(String e2:e) {
				if(e2 == "" || e2 == null) e2 = "null";
				showTable.append(setWidth(e2, maxLen[j])+"  |  ");
				j++;
			}
			i++;
			showTable.append("\n");
		}
		return showTable.toString();
	}
	
	public String getTable(boolean isHTML) {
		if(isHTML == false) {
			return getTable();
		}
		
		StringBuffer showTable = new StringBuffer();
		int i = 0;
		int j = 0;
		showTable.append("<table class='sql_table sql_table_"+table_nm+"'>");
		for(String[] e:data) {
			j = 0;
			showTable.append("<tr class='sql_tr_"+i+" sql_tr'>");
			for(String e2:e) {
				if(e2 == "" || e2 == null) e2 = "null";
				showTable.append("<td class='sql_td_"+j+" sql_td'>"+e2+"</td>");
				j++;
			}
			showTable.append("</tr>");
			i++;
		}
		showTable.append("</table>");
		table_nm++;
		return showTable.toString();
	}

	public String getJSON() {
		StringBuffer JSONResult = new StringBuffer();
		JSONResult.append("[");
		for (int i=1;i<data.length;i++) {
			JSONResult.append("{");
			for (int j=0;j<data[0].length;j++) {
				JSONResult.append(data[0][j]+":"+data[i][j]);
				if (data[0].length-1 != j) {
					JSONResult.append(",");
				}
			}
			JSONResult.append("}");
			if (data.length-1 != i) {
				JSONResult.append(",");
			}
		}
		JSONResult.append("]");

		return JSONResult.toString();
	}
	
	public int getTableNo() {
		return table_nm;
	}
	
	protected int getWidth(String str) {
		Font font = new Font("Arial", Font.PLAIN, 12);
		FontRenderContext frc = new FontRenderContext(new AffineTransform(), true, true);
		int textwidth = (int)(font.getStringBounds(str, frc).getWidth());
		return textwidth;
	}
	
	protected String setWidth(String str, int width) {
		int strWidth = getWidth(str);
		int count = (width-strWidth) / 3 + 2;
		Pattern pattern = Pattern.compile("[ㄱ-ㅎ|ㅏ-ㅣ|가-힣|a-z|A-Z|0-9]");
		Matcher matcher = pattern.matcher(str);
		long matches = matcher.results().count();
		count -= matches;
		for(int i=0;i<count;i++) {
			str += " ";
		}
		
		return str;
	}
}