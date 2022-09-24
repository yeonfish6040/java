package sha256_decoder;

import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import java.util.Scanner;
import java.io.File;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import util.Stopwatch;

public class main {
    public static void main(String[] args) throws IOException {
        Scanner sc = new Scanner(System.in);
        System.out.print("몇줄이나 쓸겨? ");
        int i = sc.nextInt();
        Boolean go = false;
        Stopwatch.Flag();
        while(true) {
            Scanner scF = new Scanner(new File("shaKeys.db"));
            String StartStr = "";
            while (scF.hasNextLine()) {
                StartStr = scF.nextLine();
            }
            System.out.println(StartStr);
            StartStr = StartStr.split("!=!")[0];
            System.out.println(StartStr);
            String[] strList = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "`", "~", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_", "=", "+", "{", "[", "}", "]", "|", "\\", ":", ";", "\'", "\"", ",", "<", ".", ">", "/", "?", " "};
            StringBuffer lines = new StringBuffer();
            String strTemp = StartStr;
            int step;
            if(i>10000000){
                step = 10000000;
                i -= 10000000;
            }else {
                step = i;
                i = 0;
                go = true;
            }
            Stopwatch.Flag();
            while(true) {
                System.out.println(i+step);
                strTemp = strIncrease(strTemp, strList);
                if (strTemp.equals("!=!"))
                    continue;
                try{
                    String line = strTemp+"!=!"+SHA256.encrypt(strTemp)+"\n";
                    lines.append(line);
                }catch (Exception e){
                }
                step--;
                if (step == 0)
                    break;
            }
            Stopwatch.Flag();
            FileWriter fr = new FileWriter("shaKeys.db", true);
            fr.write(lines.toString());
            fr.close();
            if(go) {
                break;
            }
        }
        Stopwatch.Flag();
        System.out.println(Stopwatch.getDuration(0,3)+"ms was taken for this work");
        System.out.println(Stopwatch.getDuration(0,1)+"ms was taken for read db file");
        System.out.println(Stopwatch.getDuration(1,2)+"ms was taken for making");
        System.out.println(Stopwatch.getDuration(2, 3)+"ms was taken for saving result");
    }

    private static String strIncrease(String str, String[] strList) {
        int strListLen = strList.length;
        String result = "";
        int cutLen = 0;
        String strTemp = str;
        while(true) {
            if (strTemp.equals("")) {
                result = strList[0];
                for(int i=0;i<cutLen;i++){
                    result += strList[0];
                }
                break;
            }
            String lastChar = strTemp.substring(strTemp.length()-1);
            int pos = Arrays.asList(strList).indexOf(lastChar);
            if (lastChar.equals(strList[strListLen-1])) {
                cutLen++;
                strTemp = strTemp.substring(0, strTemp.length()-1);
            }else{
                result = strTemp.substring(0, strTemp.length()-1)+strList[pos+1];
                for(int i=0;i<cutLen;i++){
                    result += strList[0];
                }
                break;
            }
        }
        return result;
    }
}

class SHA256 {

    public static String encrypt(String text) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        md.update(text.getBytes());

        return bytesToHex(md.digest());
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder builder = new StringBuilder();
        for (byte b : bytes) {
            builder.append(String.format("%02x", b));
        }
        return builder.toString();
    }

}