package com.practice.chying.handlerexample;

import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
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
        handler = new myHandler(); // 建立handler

        btn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                // 點擊後，建立訊息並用Handler發送
                Message msg = handler.obtainMessage(); // 建立訊息
                msg.what =  (int)(Math.random()* 10); // 訊息賦值
                handler.sendMessage(msg); // 發送訊息，將訊息加入隊列
                // 1. looper將訊息從隊列取出
                // 2. looper找到與訊息對應的handler對象
                // 3. looper調用handler對象的handleMessage()方法處理訊息
            }
        });

    }


    class myHandler extends Handler{ // 自己創一個類別繼承Handler
        public void handleMessage(Message msg) {
            // handleMessage用來處理訊息
            int what = msg.what;
            System.out.println("what:"+what);
            txt.setText("handler value: "+what);
        }
    }

}
