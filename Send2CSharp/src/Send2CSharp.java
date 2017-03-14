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
		Button btn = new Button("Send"); // �m�J�@�ӡySend�z���s
		btn.setOnAction(e -> { //���U���s�ƥ�B�z���
			try {
				int size = 65536 * 6; // ���հe�X 65536*6����ƶq
				byte[] szbuf = new byte[4]; // �������N��ƶq���j�p(int)�নbyte[4]�e��server�A�H�K��t�m�����w�İ�
				for (int i = 0; i < 4; i++) // �Nint�ন4��bytes���}�C
					szbuf[i] = (byte) (0xff & (size >> (8 * i)));
				toServer.write(szbuf); // �e�X��ƶq�j�p��server
				toServer.flush(); 
				byte[] buf = new byte[size]; // �t�m�n�e�X����ơ]byte[65536*6]�^
				for (int i = 0; i < size; i++) // �H�K�]�w��Ƥ��e�A�H�K����server���줺�e�����T��
					buf[i] = (byte) (i & 0xff);
				// Send the radius to the server
				toServer.write(buf, 0, size); // �e�X���
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

	private void setupSocket() { // �}�q��server�ݪ�socket
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
