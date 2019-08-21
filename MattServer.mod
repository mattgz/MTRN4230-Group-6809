MODULE MattServer   
    PERS string In_str := "0";
    PERS string Out_str := "0";
    VAR string received_str;
    
    ! The socket connected to the client.
    VAR socketdev client_socket;
    ! The host and port that we will be listening for a connection on.
    PERS string host := "127.0.0.1";
    CONST num port := 1025;
    
    PROC Main ()
        TPWrite ">>>>>>S>>>>>>";
        IF RobOS() THEN
            host := "192.168.125.1";
        ELSE
            host := "127.0.0.1";
        ENDIF
        MainServer;
        TPWrite ">>>>>>F>>>>>>";
    ENDPROC

    PROC MainServer()
        ListenForAndAcceptConnection;
        WHILE TRUE DO
            WaitForMessage;
        ENDWHILE
        CloseConnection;
    ENDPROC

    PROC WaitForMessage()
            TPWrite ">>>>>>L>>>>>>  " + "In_str: " + In_str + "   Out_str: " + Out_str; 
            IF In_str = "0" THEN
                ! Receive a string from the client.
                SocketReceive client_socket \Str:=received_str;
                In_str := received_str;
                TPWrite "Got new string" + In_str;
                SocketSend client_socket \Str:=("ACK" + "\0A");  
                MattMain;
            ENDIF
            
            SocketSend client_socket \Str:=(received_str + "\0A");    
            
            IF Out_str <> "0" THEN
                TPWrite "Sending string" + Out_str;
                ! Send the string back to the client, adding a line feed character.
                SocketSend client_socket \Str:=(Out_str + "\0A");
                Out_str := "0";
            ENDIF
            
    ENDPROC
    
    PROC ListenForAndAcceptConnection()
        
        ! Create the socket to listen for a connection on.
        VAR socketdev welcome_socket;
        SocketCreate welcome_socket;
        
        ! Bind the socket to the host and port.
        SocketBind welcome_socket, host, port;
        
        ! Listen on the welcome socket.
        SocketListen welcome_socket;
        
        ! Accept a connection on the host and port.
        SocketAccept welcome_socket, client_socket \Time:=WAIT_MAX;
    
        ! Close the welcome socket, as it is no longer needed.
        SocketClose welcome_socket;
        
    ENDPROC
    
    ! Close the connection to the client.
    PROC CloseConnection()
        SocketClose client_socket;
    ENDPROC
    

ENDMODULE