package com.practice.chying.handlerexample2;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    private Button btn;
    private TextView txt;
    private Handler handler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        btn = (Button) findViewById(R.id.btn);
        txt = (TextView) findViewById(R.id.txt);
        handler = new MyHandler();

        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                System.out.println("MainThread: " + Thread.currentThread().getName());

                Thread t = new NetworkThread();
                t.start();
            }
        });

    }

    class MyHandler extends Handler{
        public void handleMessage(Message msg){
            System.out.println("HandleMessage: " + Thread.currentThread().getName());
            String s = (String) msg.obj;
            txt.setText(s);
        }
    }

    class NetworkThread extends Thread{
        @Override // 錯誤會提示
        public void run(){

            System.out.println("NetworkThread: " + Thread.currentThread().getName());
            // 模擬發送訊息到server，休眠2秒
            try {
                Thread.sleep(1*1000);
            }catch (InterruptedException e){
                e.printStackTrace();
            }

           // 得到回傳值後更新到textView
            int num = (int)(Math.random()* 100); // 訊息賦值
            String s = "回傳值為:"+num;
            // txt.setText(s); // 這行報錯，textView只能在Main thread中操作UI
            // 所以要透過handler來更新UI的值
            Message msg = handler.obtainMessage();
            msg.obj = s;
            handler.sendMessage(msg);
        }
    }
}
