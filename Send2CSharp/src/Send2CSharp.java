import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;

public class Send2CSharp extends Application {
	DataOutputStream toServer = null;
	Socket socket;

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		launch(args);
	}

	@Override
	public void start(Stage stage) throws Exception {
		// TODO Auto-generated method stub
		BorderPane pane = new BorderPane();
		Button btn = new Button("Send"); // 置入一個『Send』按鈕
		btn.setOnAction(e -> { //註冊按鈕事件處理函數
			try {
				int size = 65536 * 6; // 測試送出 65536*6的資料量
				byte[] szbuf = new byte[4]; // 必須先將資料量的大小(int)轉成byte[4]送給server，以便其配置接收緩衝區
				for (int i = 0; i < 4; i++) // 將int轉成4個bytes的陣列
					szbuf[i] = (byte) (0xff & (size >> (8 * i)));
				toServer.write(szbuf); // 送出資料量大小到server
				toServer.flush(); 
				byte[] buf = new byte[size]; // 配置要送出的資料（byte[65536*6]）
				for (int i = 0; i < size; i++) // 隨便設定資料內容，以便檢驗server收到內容之正確性
					buf[i] = (byte) (i & 0xff);
				// Send the radius to the server
				toServer.write(buf, 0, size); // 送出資料
				toServer.flush();
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		});
		pane.setCenter(btn);
		Scene scene = new Scene(pane, 450, 200);
		stage.setTitle("Client"); // Set the stage title
		stage.setScene(scene); // Place the scene in the stage
		stage.show(); // Display the stage

		setupSocket();
	}

	private void setupSocket() { // 開通到server端的socket
		// TODO Auto-generated method stub
		try {
			// Create a socket to connect to the server
			socket = new Socket("127.0.0.1", 100);
			// Create an output stream to send data to the server
			toServer = new DataOutputStream(socket.getOutputStream());
		} catch (IOException ex) {
			System.out.println(ex.toString() + '\n');
		}
	}

}
