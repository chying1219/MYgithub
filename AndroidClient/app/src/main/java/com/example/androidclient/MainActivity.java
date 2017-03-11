package com.example.androidclient;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Base64;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.Socket;

public class MainActivity extends Activity {

	private static TextView textResponse;
	private EditText editTextAddress, editTextPort;
	private ImageView imgImageView;
	private Button buttonConnect;
	private Button buttonSendImage;
	private String message = "Hi client!";
	private static String kq = "";
	private ClientTask myClientTask;
	private OnListener listener;
	private static boolean flag = true;
	Socket socket = null;

	public interface OnListener {
		void listener(String text);
	}

	public void addListener(OnListener listener) {
		this.listener = listener;
	}

	static Handler handler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			if (flag) {
				kq += msg.obj.toString() + "\r\n";
				textResponse.setText(kq);
			}
		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		editTextAddress = (EditText) findViewById(R.id.address);
		editTextPort = (EditText) findViewById(R.id.port);
		buttonConnect = (Button) findViewById(R.id.connect);
		textResponse = (TextView) findViewById(R.id.response);
		imgImageView = (ImageView) findViewById(R.id.img);
		buttonSendImage = (Button) findViewById(R.id.sendimage);

		buttonConnect.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				myClientTask = new ClientTask(editTextAddress.getText()
						.toString(), Integer.parseInt(editTextPort.getText()
						.toString()));
				myClientTask.execute();
			}
		});


		buttonSendImage.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				encodeImage();
				//SendImge();
			}
		});

	}



	public class ClientTask extends AsyncTask<String, String, String> implements
			OnListener {

		String dstAddress;
		int dstPort;
		PrintWriter out1;


		ClientTask(String addr, int port) {
			dstAddress = addr;
			dstPort = port;
		}

		@Override
		protected void onProgressUpdate(String... values) {
			// TODO Auto-generated method stub
			super.onProgressUpdate(values);

		}

		@Override
		protected String doInBackground(String... params) {
			// TODO Auto-generated method stub

			try {

				socket = new Socket(dstAddress, dstPort);	// 透過ip位置，連接到 c#
				out1 = new PrintWriter(socket.getOutputStream(), true);
				//out1.print("Hello server!");
				out1.flush();

				BufferedReader in1 = new BufferedReader(new InputStreamReader(
						socket.getInputStream()));
				do {
					try {
						if (!in1.ready()) {
							if (message != null) {	// 表示有連接到
								// encodeImage();
								MainActivity.handler.obtainMessage(0, 0, -1,
										"Server: " + message).sendToTarget();
								message = "";
							}
						}
						// 無限制的接收從c#來的文字
						int num = in1.read();
						message += Character.toString((char) num);
					} catch (Exception classNot) {
					}

				} while (!message.equals("bye"));

				try {
					sendMessage("bye");
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} finally {
					socket.close();
				}

			} catch (IOException e) {
				e.printStackTrace();
			}
			return null;
		}

		@Override
		protected void onPostExecute(String result) {
			try {
				if (socket.isClosed()) {
					flag = false;
				}
			} catch (Exception e) {
				Toast.makeText(getApplicationContext(), "socket import error!", Toast.LENGTH_LONG).show();
			}

			super.onPostExecute(result);
		}

		@Override
		public void listener(String text) {
			// TODO Auto-generated method stub
			sendMessage(text);
		}

		void sendMessage(String msg) {
			try {
				out1.print(msg);
				out1.flush();
				if (!msg.equals("bye"))
					MainActivity.handler.obtainMessage(0, 0, -1, "Me: " + msg)
							.sendToTarget();
				else
					MainActivity.handler.obtainMessage(0, 0, -1,
							"Disconnect!").sendToTarget();
			} catch (Exception ioException) {
				ioException.printStackTrace();
			}
		}

	}

	public void send(View v) {
		addListener(myClientTask);
		if (listener != null)
			listener.listener(((EditText) findViewById(R.id.editText1))
					.getText().toString());
	}

	public void encodeImagetest() {


		try {
			Bitmap ourbitmap = BitmapFactory.decodeResource(getResources(), R.drawable.test1);
			ByteArrayOutputStream stream = new ByteArrayOutputStream();
			ourbitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
			byte[] b = stream.toByteArray();
			String ImgEncode = Base64.encodeToString(b, Base64.DEFAULT);

			// 字串分段，1000*1000的圖轉換成字串長度為949836，為了滿足.writeUTF每次發送需<64KB
			// 所以我們以長度10000來分割字串，共可得95段，即須要發送95次
			int SubstringLen = 10000;
			int n = (ImgEncode.length()/SubstringLen)+1; // +1為沒整除，存放剩餘的字串
			String[] num = new String[n];
			int CountRemainLength = ImgEncode.length();
			int sentNum=0; // 需要發送的次數
			for(int i = 0, x=0, y=SubstringLen; i<n; i++){
				if(CountRemainLength < SubstringLen){
					// 計算剩餘的字串長度，存放未整除殘留的字串，即最後一段
					num[i]  = ImgEncode.substring(x,x+CountRemainLength);
					sentNum = i+1;
				}else
				{
					CountRemainLength = ImgEncode.length() - y;
					num[i]  = ImgEncode.substring(x,y);
					x += SubstringLen;
					y += SubstringLen;
				}
			}


			byte[] decodedBytes = Base64.decode(ImgEncode, Base64.DEFAULT);
			Bitmap showImg = BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);

		/* Example usage:
		String myBase64Image = encodeToBase64(myBitmap, Bitmap.CompressFormat.JPEG, 100);
		Bitmap myBitmapAgain = decodeBase64(myBase64Image);
		* */
			DataOutputStream dataOutputStream = new DataOutputStream(socket.getOutputStream());


			for(int j = 0; j<3; j++){ // 發送sentNum次
				dataOutputStream.writeUTF(num[j]);
			}

			// dataOutputStream.writeUTF(num[94]);
			// dataOutputStream.writeUTF(ImgEncode);	//dataOutputStream.write(b);
			dataOutputStream.flush();
			// dataOutputStream.close();
			imgImageView.setImageBitmap(showImg);
			// int a = 1;

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void encodeImage() {

		try {
			Bitmap ourbitmap = BitmapFactory.decodeResource(getResources(), R.drawable.test1);
			ByteArrayOutputStream stream = new ByteArrayOutputStream();
			ourbitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
			byte[] b = stream.toByteArray();
			String ImgEncode = Base64.encodeToString(b, Base64.DEFAULT);

			// 字串分段，1000*1000的圖轉換成字串長度為949836，為了滿足.writeUTF每次發送需<64KB
			// 所以我們以長度10000來分割字串，共可得95段，即須要發送95次
			int SubstringLen = 10000;
			int n = (ImgEncode.length()/SubstringLen)+1; // +1為沒整除，存放剩餘的字串
			String[] num = new String[n];
			int CountRemainLength = ImgEncode.length();
			int sentNum=0;

			for(int i = 0, x=0, y=SubstringLen; i<n; i++){
				if(CountRemainLength < SubstringLen){
					// 計算剩餘的字串長度，存放未整除殘留的字串，即最後一段
					num[i]  = ImgEncode.substring(x,x+CountRemainLength);
					sentNum = i+1;
				}else
				{
					CountRemainLength = ImgEncode.length() - y;
					num[i]  = ImgEncode.substring(x,y);
					x += SubstringLen;
					y += SubstringLen;
				}
			}

			byte[] decodedBytes = Base64.decode(ImgEncode, Base64.DEFAULT);
			Bitmap showImg = BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
		/* Example usage:
		String myBase64Image = encodeToBase64(myBitmap, Bitmap.CompressFormat.JPEG, 100);
		Bitmap myBitmapAgain = decodeBase64(myBase64Image);
		* */
			DataOutputStream dataOutputStream = new DataOutputStream(socket.getOutputStream());


			for(int j = 0; j<sentNum; j++){ // 發送sentNum次
				dataOutputStream.writeUTF(num[j]);
				dataOutputStream.flush();
			}

			// dataOutputStream.writeUTF(num[94]);
			// dataOutputStream.writeUTF(ImgEncode);	//dataOutputStream.write(b);
			// dataOutputStream.flush(); <--

			// dataOutputStream.close();
			imgImageView.setImageBitmap(showImg);
			// int a = 1;

		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void SendImge() {
		// 不需要解碼，直接傳圖片格式
		try {
			Bitmap ourbitmap = BitmapFactory.decodeResource(getResources(), R.drawable.ic_launcher);
			ByteArrayOutputStream stream = new ByteArrayOutputStream();
			ourbitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
			byte[] b = stream.toByteArray();

			OutputStream os = socket.getOutputStream();
			os.write(b,0,b.length);
			os.flush();
			socket.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}


	/*
	public void sendImage2(File file) {

		File file = new File(
				Environment.getExternalStorageDirectory(),
				"test.png");

		ObjectInputStream ois = new ObjectInputStream(socket.getInputStream());
		byte[] bytes;
		FileOutputStream fos = null;
		try {
			bytes = (byte[])ois.readObject();
			fos = new FileOutputStream(file);
			fos.write(bytes);
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			if (fos != null) {
				fos.close();
			}
		}

	}
	*/


	// send image
	public void sendImage() {

		File file = new File(
				Environment.getExternalStorageDirectory(),
				"/demo/takepicture.jpg");

		try {
			DataOutputStream outImg = new DataOutputStream(
					socket.getOutputStream());
			outImg.writeChar('I'); // as image,
			DataInputStream dis = new DataInputStream(new FileInputStream(file));
			ByteArrayOutputStream ao = new ByteArrayOutputStream(); // image to byte array
			/* // or other function:
			// First try to convert your captured bitmap to byte array like:
			ByteArrayOutputStream stream = new ByteArrayOutputStream();
			bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
			byte[] byteArray = stream.toByteArray();
			*/
			int read = 0;
			byte[] buf = new byte[1024];
			while ((read = dis.read(buf)) > -1) {
				ao.write(buf, 0, read);
			}
			outImg.writeLong(ao.size());
			outImg.write(ao.toByteArray());
			outImg.flush();
			outImg.close();
			dis.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		// Then you can write byte array to an OutputStream
		// which is received by call socket.getOutputStream().
		// Next is your work in server side
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		try {
			if (listener != null)
				listener.listener("bye");
			socket.close();
		} catch (Exception e) {
			// TODO: handle exception
		}
		super.onDestroy();
	}
	
	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		try {
			if (listener != null)
				listener.listener("bye");
			socket.close();
		} catch (Exception e) {
			// TODO: handle exception
		}
		super.onStop();
	}
	
	public void onClick(View v) {
		Intent intent = new Intent(getApplicationContext(), MainActivity.class);
		startActivity(intent);
		finish();
	}



}
